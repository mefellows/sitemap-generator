require 'sitemap/logging'
require 'open-uri'
require 'net/http'

# Public: Transformers are objects that modify a provided link.
#
# For example, a Transformer might be used to strip out query string URLS
# before indexing.
module Transformers
  class Util
    # Public: Apply URI transformers to a Hash.
    #
    # uris      - Set (Array|Hash) of URIs to be filtered.
    # index     - Current index
    # base_uri  - Base URI to test against
    # transformers   - transformers to reduce set of uris
    #
    # Returns a filtered uris Hash
    def self.apply_transformers(uris, transformers)

      # Clone transformers so we retain the 'functional' style of no side-effects
      transformers_clone = transformers.clone

      # Check for terminating case
      if (!uris.nil? && uris.length > 0)

        if !transformers_clone.nil? && transformers_clone.length > 0

          # Pop a transformer and apply it recursively to the result of the next transformer
          t = transformers_clone.shift
          uris = apply_transformers(uris, transformers_clone)

          uris = uris.map do |k,v|
            t.transform(k)
          end
        end
      end

      uris
    end

    #
    # Public: Get all known transformers
    #
    def self.get_all_transformers
      return [Transformers::URIQueryStringTransformer.new]
    end

  end

  # Public: URI Query Sttring Transformer.
  #
  #
  class URIQueryStringTransformer
    include Logging

    #
    # Public: Filters out URLs with query string resources.
    #
    # Returns the link without the query string component
    #
    def transform(link)
      link = Filters::Util.make_URI(link)
      return link unless (link != nil && link.query != nil)
      link.query = nil
      link
    end
  end

end