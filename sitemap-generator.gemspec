# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemap-analyser"
  spec.version       = Sitemap::VERSION
  spec.authors       = ["mefellows"]
  spec.email         = ["matt.fellows@onegeek.com.au"]
  spec.description   = "A basic, human readable sitemap generator"
  spec.summary       = "A basic, human readable sitemap generator"
  spec.homepage      = "https://github.com/mefellows/sitemap-generator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "clamp"
  spec.add_runtime_dependency "log4r"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "bson_ext"
end
