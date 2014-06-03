require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/param'
require 'sitemap/version'
require 'sitemap/logging'
require 'sitemap/commands/sitemap'
require 'sitemap/filters/transformers'
#
# Public: Front end API for the Sitemap Generator website
#
module Sitemap
  module Routes
    class Web < Sinatra::Application
      include Logging

      configure do
        set :views,         'app/views'
        set :public_folder, 'public/app'
      end

      # Public: Main HTML web page to interact with app
      #
      #
      get '/' do
        erb :home
      end

      #
      # Public: 404 page
      #
      not_found do
        'This is nowhere to be found.'
      end

      #
      # Public: Error page
      #
      error do
        # 'Im sorry, <a href=http://github.com/mefellows/> this guy</a> wrote some shit code and hasnt improved it yet. He did say this was experimental though!"
        'Im sorry, <a href="http://github.com/mefellows/">this guy</a>" wrote some shit code and hasnt improved it yet. He did say this was experimental though!'
      end

    end
  end
end