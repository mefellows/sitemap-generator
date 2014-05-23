# require 'rspec'
# require 'substantiate/commands/sitemap'
# require 'spec_helper'

# describe SitemapGenerator do

#   it 'Should ' do

#     importer = Import.new
#     import.to_radians(5).should == 7.839325190887568e-06
#   end
# end

#describe Bowling, "#score" do
#  it "returns 0 for all gutter game" do
#    bowling = Bowling.new
#    20.times { bowling.hit(0) }
#    bowling.score.should eq(0)
#  end
#end

require 'rspec'
require 'sitemap/commands/sitemap'
require 'spec_helper'

describe SitemapGenerator do

  it 'Should exclude non-local URIs' do
    generator = SitemapGenerator.new
    generator.isLinkLocal('http://foo.com/foo/bar', 'http://www.foo.com/something').should eq(false)
    generator.isLinkLocal('http://foo.com/foo/bar', 'https://www.foo.com/something').should eq(false)
    generator.isLinkLocal('http://foo.com/foo/bar', 'http://www.somethingelse.com/something').should eq(false)
    generator.isLinkLocal('http://foo.com/foo/bar', 'https://www.somethingelse.com/something').should eq(false)
  end

  it 'Should include relative URIs' do
    generator = SitemapGenerator.new
    generator.isLinkLocal('http://foo.com/foo/bar', '/something').should eq(true)
  end

  it 'Should include absolute local URIs' do
    generator = SitemapGenerator.new
    generator.isLinkLocal('http://foo.com/foo/bar', 'http://foo.com/something').should eq(true)
    generator.isLinkLocal('http://foo.com/foo/bar', 'https://foo.com/something').should eq(true)
  end

end