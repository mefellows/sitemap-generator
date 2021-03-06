# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemap-generator"
  spec.version       = Sitemap::VERSION
  spec.authors       = ["mefellows"]
  spec.email         = ["matt.fellows@onegeek.com.au"]
  spec.summary       = "Sitemap Generator"
  spec.description   = "A basic, human readable (CSV, JSON) sitemap generator. "
  spec.homepage      = "https://github.com/mefellows/sitemap-generator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  # spec.add_development_dependency "sass", "~>3.3.7"

  spec.add_runtime_dependency "rspec"
  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "clamp"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "log4r"
  spec.add_runtime_dependency "nokogiri", "1.5.11"
  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "sinatra-contrib"
  spec.add_runtime_dependency "sinatra-param"
  # spec.add_runtime_dependency "async_sinatra"
  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "em-websocket"
  # spec.add_runtime_dependency "unicorn"
  spec.add_runtime_dependency "thin"
  # spec.add_runtime_dependency "puma"
  spec.add_runtime_dependency "foreman"
  spec.add_runtime_dependency "dotenv"
  spec.add_runtime_dependency "sinatra-websocket"
  spec.add_runtime_dependency "compass"
end
