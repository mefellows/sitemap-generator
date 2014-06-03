require 'sinatra/base'
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
    class API < Sinatra::Application
      include Logging
      helpers Sinatra::Param

      configure do
        set :json_encoder, :to_json
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
      # Avoid using this as it is blacing-IO
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

        # index = generator.generate(url, nil, filters, transformers, 'json', params[:depth])
        index = generator.generate(url, nil, filters, transformers, 'json', 1)
        index.to_s
        # index.to_json
      end

      #
      # Public: Dummy route to test UI and for examples
      #
      get '/api/dummy' do
        '{"http://www.onegeek.com.au":{"title":"Usability, Web Standards & Design | Matthew Fellows"},"http://www.onegeek.com.au/":{"title":"Usability, Web Standards & Design | Matthew Fellows"},"http://www.onegeek.com.au/category/articles/":{"title":"Articles | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/projects/":{"title":null},"http://www.onegeek.com.au/journal/":{"title":null},"http://www.onegeek.com.au/about/":{"title":null},"http://www.onegeek.com.au/about":{"title":"About Me | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/category/projects":{"title":"Projects | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/blog/570":{"title":"Taking back content | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/journal/scrum-my-life":{"title":"Scrum my life | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/articles/2014-thoughtworks-tech-radar":{"title":"2014 Thoughtworks Tech Radar | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/articles/development-articles/load-time-weaving-in-fuse-esb-equinox-aspect":{"title":"Load Time Weaving in Fuse ESB (Apache ServiceMix) with Equinox Aspects | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/rest-api/polymorphic-payloads-in-restful-api-using-apache-cxfjax-rs":{"title":"Polymorphic Payloads in RESTful API using Apache CXF/JAX-RS | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/javascript-form-validation":{"title":null},"http://www.onegeek.com.au/javascript-serializer":{"title":null},"http://www.onegeek.com.au/javascript-form-state-recovery":{"title":null},"http://www.onegeek.com.au/contact":{"title":"Contact | Usability, Web Standards & Design | OneGeek"},"http://www.onegeek.com.au/feed":{"title":"Usability, Web Standards & Design | OneGeek"}}'
      end

      # Public: Socket connection endpoint for long-running API requests.
      #
      # Typically, longer running API calls would be wrapped into a Worker process,
      # but this means we can be tight-arses and leverage free Heroku instances :)
      #
      get '/socket' do
        if !request.websocket?
          JSON::generate({'data' => {}, 'error' => 'Invalid WebSocket request'})
        else
          response_obj = {'data' => {}, 'message' => 'Invalid Request'}
          request.websocket do |ws|
            ws.onopen do
              warn("socket opened")
              settings.sockets << ws
            end
            ws.onmessage do |msg|
              response_obj = {'message' => {}, 'error' => 'Invalid request'}
              EM.next_tick {
                json_msg = JSON.parse(msg)

                # Do not remove the 'pong' response
                # TODO: move this into an abstraction somewhere so it's hidden
                pong = checkPong(json_msg)
                if (!pong.nil?)
                  response_obj = pong
                  ws.send(JSON::generate(response_obj))
                elsif json_msg.has_key?('url')

                  # Fiber.new {
                  EM::defer(proc {
                    warn("Creating fiber...")
                    url = json_msg['url']
                    warn("Looking up #{url}")
                    generator = SitemapGenerator.new
                    filters = Filters::Util.get_all_filters
                    transformers = Transformers::Util.get_all_transformers

                    depth = -1
                    if json_msg.has_key?('depth')
                      depth = json_msg['depth']
                    end
                    index = generator.generate(url, nil, filters, transformers, 'object', depth)

                    # index = {'http://foo.com' => {'title' => 'Foo'}, 'http://bar.com' => {'title' => 'Bar'}}
                    response_obj = {'message' => index}
                    warn("Have response to return to a socket...")

                    # Send to ALL sockets
                    # settings.sockets.each { |s| s.send(JSON::generate(response_obj)) }

                    # Send to socket that sent this request...
                    ws.send(JSON::generate(response_obj))
                  }, proc { |result|
                    warn('result from defer: ' + result.to_s)
                  })

                  warn "(Async stuff happening)"

                end
              }
            end
            ws.onclose do
              warn("websocket closed")
              settings.sockets.delete(ws)
            end
          end
        end
      end

      # Public: Keep-alive check.
      #
      # Defaults to look for for a 'ping' message, responds with a 'pong'
      # Override this for custom behaviour.
      #
      def checkPong(msg)
        if msg.has_key?('message')
          log.debug("Checking ping pong for a ping: " + msg['message'])
          if (msg['message'] == 'ping')
            log.debug("Ping hit!")
            response_obj = {'message' => 'pong'}
          end
        end
      end
    end

  end
end