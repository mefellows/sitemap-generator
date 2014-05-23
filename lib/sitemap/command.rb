require 'sitemap/version'
require 'sitemap/logging'
require 'sitemap/commands/sitemap'
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
      option "--recursive", "recursive", "Finds recursive URLs from the provided base URI", :attribute_name => :recursive, :default => true
      #option "--no-restriction", "no-restriction", "Disables default restriction of links ", :attribute_name => :no_restriction, :default => false
      option "--restrict-path", "restrict-path", "Restrict links not on supplied path", :attribute_name => :restrict_path, :multivalued => true
      parameter "uri", "URI base to fetch URLs from", :attribute_name => :uri do |u|
        begin
          parsed_uri = URI::parse(u)
          parsed_uri
        rescue
          puts "Invalid URI provided"
          exit(0)
        end
      end
      parameter "output_file", "Output file", :attribute_name => :output_file

    def execute
      log.info('Running sitemap generator')
      generator = SitemapGenerator.new()
      generator.generate(uri, output_file, restrict_path, recursive)
    end
  end

  class MainCommand < AbstractCommand
    subcommand "sitemap", "Generate a sitemap", Sitemap::SitemapCommand
  end
end