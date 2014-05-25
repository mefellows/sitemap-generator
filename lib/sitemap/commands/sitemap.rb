require 'sitemap/logging'
require 'sitemap/filters/filters'
require 'sitemap/filters/transformers'
require 'csv'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'net/http'

class SitemapGenerator
  include Logging

  def initialize()
    log.debug('Initialising generator')
  end

  #
  # Public: Output the index to JSON
  #
  def write_index_to_json(index)
    puts JSON::generate(index)
  end

  #
  # Public: Write a Sitemap index to file
  #
  def write_index_to_file(index, output_file)
    csv = CSV.open(output_file, 'wb')
    csv << ['URI', 'Title']

    # Flush Sitemap to CSV
    index.each do |key, value|
      csv << [key, value['title']]
    end

  end

  #
  # Public: Create the index recursively.
  #
  # link          - The URI to build the index from recursively.
  # base_uri      - The base URI (Host) to restrict which links are indexed
  # filters       - An array of Filters to be applied before indexing
  # transformers  - An array of Transformers to be applied before indexing
  # link_index    - Any index to start the build from.
  # depth         - The depth of recursion. 1 for no recursion, -1 for infinite, > 1 for specific depth
  #
  # Returns an index containing URIs as keys and an object representing the page.
  #
  def create_index(link, base_uri, filters, transformers, link_index = nil, depth = -1)
    if link_index.nil?
      log.debug('Creating new Index')
      link_index = Hash.new
    end

    if link.nil? || base_uri.nil?
      return
    end

    if (Filters::Util.apply_filters([link], link_index, base_uri, filters).length > 0)

      log.debug("Indexing document #{link} with base #{base_uri}, depth #{depth} and filters #{filters}")

      # Only continue in this part if page NOT in index and is indexable
      # Only fetch the document if it's not yet been indexed
      doc = get_document(link)

      ## All docs must be indexed, even if blacklisted...

      if !doc.nil?
        log.debug("New document found at #{link}, exploring links")
        depth = depth - 1

        # Set page title and add to index
        link_index[link.to_s] = {'title' => doc.title}
        log.info("Adding link to index: #{link.to_s}")

        # Find all links on the page
        links = []
        doc.css('a').each do |l|
           links << l.attributes["href"].to_s
        end

        # Transform URLs before indexing
        Transformers::Util.apply_transformers(links, transformers)

        # Filter out in-eligible links
        Filters::Util.apply_filters(links, link_index, base_uri, filters)

        links.each do |l|
          l = Filters::Util.remove_fragment_from_uri(l)
          if l && !l.empty?
            if depth != -1
              create_index(Filters::Util.create_absolute_uri(l, base_uri), base_uri, filters,  transformers, link_index, depth)
            end
          end
        end
      end

    end

    link_index
  end

  #
  # Public: Fetch a document from the Internet.
  #
  def fetch(uri, domain = nil, limit = 10)
    uri = Filters::Util.make_URI(uri)
    if domain.nil?
      domain = uri
    end
    domain = Filters::Util.make_URI(domain)

    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(uri)

    case response
      when Net::HTTPSuccess then
        response.body
      when Net::HTTPRedirection then
        location = response['location']
        location = Filters::Util.create_absolute_uri(location, uri)
        log.warn("Redirecting #{uri} to new location: #{location}")

        # Check new location belongs to current domain
        if location.host == domain.host
          fetch(location, uri, limit - 1)
        elsif
          log.warn("Redirecting from #{uri} to #{location} rejected due to cross-domain restrictions")
        end
        nil
      else
        nil
    end
  end

  #
  # Public: Fetch a document
  #
  def get_document(uri)
    log.debug("Fetching document at #{uri}")
    begin
      response = fetch(uri.to_s)
      doc = Nokogiri::HTML(response)
      if doc.instance_of? Nokogiri::HTML::Document
        return doc
      end
    rescue StandardError => bang
      log.error("Error reading document #{uri}: #{bang.message}")
      nil
    end
  end

  #
  # Create the Sitemap
  #
  def generate(uri, output_file, filters, transformers, format = 'csv', depth = -1)

    log.debug("Generating sitemap from #{uri} to #{format} (output file? #{output_file}). Depth of recursion: #{depth}")
    index = create_index(uri, uri, filters, transformers, nil, depth)

    case format
      when 'json'
        write_index_to_json(index)
      when 'csv'
        write_index_to_file(index, output_file)
      else
        puts "Please specify a valid output format, you gave #{format} Options are ['csv', 'json']"
        exit(1)
    end
  end

end