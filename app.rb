require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/param'
require 'sitemap/version'
require 'sitemap/logging'
require 'sitemap/commands/sitemap'
require 'sitemap/filters/transformers'
require './app/routes/web'
require './app/routes/api'
require 'eventmachine'

#
# Public: Front end API for the Sitemap Generator website
#
module Sitemap
  EventMachine.run do
    class SitemapApplication < Sinatra::Application

      configure { set :server, 'thin' }
      use Rack::Deflater
      use Sitemap::Routes::API
      use Sitemap::Routes::Web

      get '/status' do
        "alive"
      end

      run!

    end
  end
end