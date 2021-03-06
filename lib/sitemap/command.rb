require 'sitemap/version'
require 'sitemap/logging'
require 'sitemap/commands/sitemap'
require 'sitemap/filters/transformers'
require 'clamp'

module Sitemap
  class AbstractCommand < Clamp::Command
    include Logging

    option ["-v", "--verbose"], :flag, "be verbose"
    option "--version", :flag, "show version" do
      puts "Sitemap Analyser " + Sitemap::VERSION
      exit(0)
    end

  end

  class SitemapCommand < AbstractCommand
      option "--no-recursion", :flag, "Prevents sitemap recursion", :default => false
      option "--format", "format", "Specify the output format. Options are [csv, json]", :attribute_name => :format, :default => 'csv'
      option "--query-strings", :flag, "Allow query strings in URIs", :default => false
      option "--fragments", :flag, "Allow fragments in URIs", :default => false
      option "--depth", "depth", "Level of depth to recurse", :attribute_name => :depth, :default => -1 do |s|
        Integer(s)
      end

      # option "--restrict-path", "restrict-path", "Restrict links not on supplied path", :attribute_name => :restrict_path, :multivalued => true
      # --follow-redirects, "follow", "Ignore redirects?"
      # --include-resources, "include resources", "Follows links to static resources such as images, videos etc."

      parameter "uri", "URI base to fetch URLs from", :attribute_name => :uri do |u|
        begin
          parsed_uri = URI::parse(u)
          parsed_uri
        rescue
          puts "Invalid URI provided"
          exit(0)
        end
      end
      parameter "[output_file]", "Output file", :attribute_name => :output_file

    def execute
      if !format.eql?('json') && output_file.nil?
        signal_usage_error "'output_file' parameter must be provided if format is not JSON."
        exit(0)
      end

      real_depth = depth
      if no_recursion?
        log.debug("Recursion disabled, setting depth to 1")
        real_depth = 1
      end

      log.info('Running sitemap generator')
      generator = SitemapGenerator.new()

      # Setup filters and transformers
      filters = Filters::Util.get_all_filters
      transformers = Transformers::Util.get_all_transformers

      # If query strings enabled, remove QueryString transformer
      if query_strings?
        transformers = transformers.select do |t|
          next true unless t.instance_of? Transformers::URIQueryStringTransformer
          false
        end
      end

      # If fragments enabled, remove URIFragmentFilter transformer
      if fragments?
        filters = filters.select do |t|
          next true unless t.instance_of? Filters::URIFragmentFilter
          false
        end
      end

      # Create the sitemap!
      result = generator.generate(uri, output_file, filters, transformers, format, real_depth)

      # TODO: Works for JSON, probably not so useful for write to file...
      puts result
    end
  end

  class MainCommand < AbstractCommand
    subcommand "generate", "Generate a sitemap", Sitemap::SitemapCommand
  end
end