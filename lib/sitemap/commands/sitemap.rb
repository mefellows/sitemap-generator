require 'sitemap/logging'
require 'json'
require 'csv'
# require 'mechanize'
require 'nokogiri'
require 'open-uri'

class SitemapGenerator
  include Logging

  def initialize()
    log.debug('Initialising generator')
  end


  #
  # Generates sitemap in parallel
  #
  def generateParallel()

  end


  #
  # Generates a sitemap in a hierarchical format
  #
  def generateHierarchical()

  end

  #
  # Determines if a link is on the local domain + path or not
  #
  def isLinkLocal(link, local, path = []  )
    return false
  end

  #
  # Write a Sitemap index to file
  #
  def writeIndexToFile(index, output_file)
    csv = CSV.open(output_file, 'wb')
    csv << ['URI', 'Link', 'Title']

    # Flush Sitemap to CSV
    index.each do |key, value|
      csv << [key, value['content'], value['title']]
      puts key
    end

  end

  #
  # Create the index
  # @param uri URI object
  #
  def createIndex(uri, restrict)
    link_index = Hash.new
    doc = Nokogiri::HTML(open(uri))

    # Find all links on the page
    doc.css('a').each do |link|

      # Add entry to index
      href = link.attributes["href"]
      if (!link_index.has_key?(href) && isLinkLocal(href, uri.host, restrict))
        link_index[href] = {'content' => link.content, 'title' => '', 'indexed' => false}
      end

    end

    link_index
  end

  #
  # Create the Sitemap
  #
  def generate(uri, output_file, restrict_path = false, recurse = true)

    log.debug("Generating sitemap from #{uri} to #{output_file}. Recurse? #{recurse}")

    index = createIndex(uri, restrict_path)
    writeIndexToFile(index, output_file)
    puts index
  end

end