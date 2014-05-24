require 'sitemap/logging'
require 'open-uri'
require 'net/http'

# Public: Various index filtering operations and classes.
module Filters

  class Util
    #
    # Idempotently make a string a URI
    #
    def self.make_URI(uri)
      begin
        if !uri.is_a? URI
          uri = URI::parse(uri)
        end
        uri
      rescue
        nil
      end
    end

    #
    # Public: Remove fragments from a URI
    #
    def self.remove_fragment_from_uri(uri)
      parsed_href = Filters::Util.make_URI(uri)
      if parsed_href.nil?
        return nil
      end
      parsed_href.fragment = nil
      parsed_href.to_s
    end

    #
    # Public: Create an absolute link provided a link and base URI.
    #
    def self.create_absolute_uri(link, base_uri)
      link = Filters::Util.make_URI(link)
      base_uri = Filters::Util.make_URI(base_uri)

      # Remove path from base
      base_uri.path = ''

      # Append Path to base_uri if relative
      if !link.path.nil? && link.path.start_with?('/')
        return base_uri + link
      end

      return link
    end

    #
    # Public: Get all known filters
    #
    def self.get_all_filters
      return [Filters::ValidURIFilter.new, Filters::LocalFilter.new, Filters::ResourcesFilter.new]
    end

    # Public: Apply URI filters to a Hash.
    #
    # uris      - Set (Array|Hash) of URIs to be filtered.
    # index     - Current index
    # base_uri  - Base URI to test against
    # filters   - Filters to reduce set of uris
    #
    # Returns a filtered uris Hash
    def self.apply_filters(uris, index, base_uri, filters)

      # Clone filters so we retain the 'functional' style of no side-effects
      filters_clone = filters.clone

      # Check for terminating case
      if (!uris.nil? && uris.length > 0)

        if !filters_clone.nil? && filters_clone.length > 0

          # Pop a filter and apply it recursively to the result of the next filter
          f = filters_clone.shift
          uris = apply_filters(uris, index, base_uri, filters_clone)

          uris = uris.select do |k,v|
            f.filter(index, k, base_uri)
          end
        end
      end

      uris
    end
  end

  #
  # Public: Filters out non-local URIs
  #
  class LocalFilter
    include Logging

    #
    # Public: Determines if a link is on the local domain + path or not
    #
    def is_link_local?(link, local)

      begin
        link = Filters::Util.make_URI(link)
        local = Filters::Util.make_URI(local)

        # Remove Absolute URLs that don't refer to local domain
        if !link.host.nil? && !link.host.eql?(local.host)
          log.debug("Rejecting host #{link.host} as it doesn't match #{local.host}")
          return false
        end

        # Ensure path starts with a '/' (filters out junk URLs)
        if !link.path.nil? && !link.path.eql?('') && !link.path.start_with?('/')
          log.debug("Rejecting link #{link} as it's path (#{link.path}) doesn't start with '/'")
          return false
        end

      rescue StandardError => bang
        log.debug("Exception looking for local links: " + bang.message)
        return false
      end

      return true
    end

    #
    # Public: Determines if a link should be indexed.
    #
    # Returns boolean true iff the link is local and not indexed.
    #
    def should_index_local_link?(link, index, base_uri)
      return !index.has_key?(link.to_s) && is_link_local?(link, base_uri)
    end

    #
    # Public: Filter out resources that are not local.
    #
    # Returns the link if it should be indexed else nil.
    #
    def filter(index, link, base_uri)
      return true unless !should_index_local_link?(link, index, base_uri)
      false
    end
  end

  # Public: URI Fragment filter.
  #
  #
  class URIFragmentFilter
    include Logging

    #
    # Public: Filters out static resources.
    #
    # Returns the link if it doesn't contain a URI fragment
    #
    def filter(index, link, base_uri)
      link = Filters::Util.make_URI(link)
      return false unless  (link.nil? || !link.fragment.nil?)
      true
    end
  end

  # Public: Valid URI filter.
  #
  #
  class ValidURIFilter
    include Logging

    #
    # Public: Filters out invalid URIs.
    #
    # Returns the link if it should be indexed else nil.
    #
    def filter(index, link, base_uri)
      return true unless link.nil? || link.to_s.match(/.*\.[a-zA-Z0-9_\-\s]+(?!\/)$/)
      false
    end
  end

  # Public: Static resource filter.
  #
  #
  class ResourcesFilter
    include Logging

    #
    # Public: Filters out static resources.
    #
    # Returns the link if it should be indexed else nil.
    #
    def filter(index, link, base_uri)
      link = Filters::Util.make_URI(link)
      if link.nil? || link.path.nil? || link.path.to_s.empty?
        return true
      end
      return true unless link.path.to_s.match(/.*\.[a-zA-Z0-9_\-\s]+(?!\/)$/)
      false
    end
  end

end