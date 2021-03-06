require 'sinatra/base'
# require 'sinatra/async'
require 'eventmachine'
require 'em-websocket'
require 'sinatra/reloader'
require 'sinatra/param'
require 'sitemap/version'
require 'sitemap/logging'
require 'sitemap/commands/sitemap'
require 'sitemap/filters/transformers'
require "sinatra/json"
require "sinatra-websocket"

#
# Public: Front end API for the Sitemap Generator website
#
module Sitemap
  module Routes
    # class JSONStream
    #   include EventMachine::Deferrable
    #
    #   def stream(object)
    #     @block.call object.to_json + "\n"
    #   end
    #
    #   def each(&block)
    #     @block = block
    #   end
    # end

      class API < Sinatra::Application
        include Logging
        # register Sinatra::Async
        helpers Sinatra::Param

        configure do
          # set :json_encoder, :to_json
          set :sockets, []
        end

        before do
          content_type :json

          # CORS
          headers 'Access-Control-Allow-Origin' => '*',
                  'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
        end

        # CORS
        options '/*' do
          200
        end

        # Public: Main API entry point to run a Sitemap generation service
        #
        #
        get '/api/sitemap/:uri' do

          param :depth, String, default: -1
          param :secure, Boolean, default: false
          param :qs, Boolean, default: false
          param :fragments, String, default: false

          log.debug("Request received: #{params[:depth]}, #{params[:qs]}, #{params[:fragments]}")

          filters = Filters::Util.get_all_filters
          transformers = Transformers::Util.get_all_transformers

          prefix = 'http://'

          if params[:secure] == true
            prefix = 'https://'
          end

          url = prefix + params[:uri]

          # Create the index
          generator = SitemapGenerator.new

          index = generator.generate(url, nil, filters, transformers, 'json', params[:depth])
          index.to_s
        end

        #
        # Public: Dummy route to test UI and for examples
        #
        get '/api/dummy' do
          '{"http://www.onegeek.com.au":{"title":"Usability, Web Standards & Design | Matthew Fellows"},"http://www.onegeek.com.au/":{"title":"Usability, Web Standards & Design | Matthew Fellows"},"http://www.onegeek.com.au/category/articles/":{"title":"Articles | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/projects/":{"title":null},"http://www.onegeek.com.au/journal/":{"title":null},"http://www.onegeek.com.au/about/":{"title":null},"http://www.onegeek.com.au/about":{"title":"About Me | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/category/projects":{"title":"Projects | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/blog/570":{"title":"Taking back content | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/journal/scrum-my-life":{"title":"Scrum my life | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/articles/2014-thoughtworks-tech-radar":{"title":"2014 Thoughtworks Tech Radar | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/articles/development-articles/load-time-weaving-in-fuse-esb-equinox-aspect":{"title":"Load Time Weaving in Fuse ESB (Apache ServiceMix) with Equinox Aspects | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/rest-api/polymorphic-payloads-in-restful-api-using-apache-cxfjax-rs":{"title":"Polymorphic Payloads in RESTful API using Apache CXF/JAX-RS | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/javascript-form-validation":{"title":null},"http://www.onegeek.com.au/javascript-serializer":{"title":null},"http://www.onegeek.com.au/javascript-form-state-recovery":{"title":null},"http://www.onegeek.com.au/contact":{"title":"Contact | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/feed":{"title":"Usability, Web Standards & Design | OneGeek"}}'
        end

        get '/socket' do
          if !request.websocket?
            JSON::generate({'data' => {}, 'error' => 'Invalid WebSocket request'})
          else
            request.websocket do |ws|
              ws.onopen do
                warn("socket opened")
                # ws.send("{'data':'Hello World!'}")
                settings.sockets << ws
              end
              ws.onmessage do |msg|
                EM.next_tick {
                  json_msg = JSON.parse(msg)
                  depth = json_msg['depth'] || -1

                  filters = Filters::Util.get_all_filters
                  transformers = Transformers::Util.get_all_transformers
                  generator = SitemapGenerator.new

                  # index = {"http://www.onegeek.com.au/1" => {"title" => "Hello1"}, "http://www.onegeek.com.au/2" => {"title" => "Hello2"}, "http://www.onegeek.com.au/3" => {"title" => "Hello3"}}
                  index = generator.generate('http://' + json_msg['url'], nil, filters, transformers, 'object', depth)

                  response_obj = {'data' => index, 'callback_id' => json_msg['callback_id'] }
                  settings.sockets.each{|s| s.send(JSON::generate(response_obj)) }
                }
              end
              ws.onclose do
                warn("websocket closed")
                settings.sockets.delete(ws)
              end
            end
          end
        end
    end
  end
end