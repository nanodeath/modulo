require 'rubygems'
require 'rack'

module Modulo
  class RackApp
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def call(env)
      puts "foo!"
      response = {
        :route => nil,
        :input => nil,
        :env => env,
        :header => Rack::Utils::HeaderHash.new({'Content-Type' => 'text/html'}),
        :status => 200,
        :body => [],
        :metadata => {}
      }

      catch(:halt) do
        @pipeline.each do |stage|
          stage.call(env, response)
        end
      end

      puts response.inspect
      ret = [response[:status], response[:header], response[:body]]
      puts ret.inspect
      ret
      
    end

    def process_routers(env, response)
      route = nil
      @routers.each do |r|
        route = r.call(env)
        break unless route.nil?
      end
      response[:route] = route
    end

    def process_preprocessors(env, response)
      catch(:halt) do
        @preprocessors.each do |p|
          response = p.call(env, response)
        end
      end
    end
  end

  class Router
    module ResponseCodes
      module Informational
        CONTINUE = 100
        SWITCHING_PROTOCOLS = 101
      end

      class Successful
        # Request succeeded.
        # GET: an entity corresponding to the requested resource is sent in the response
        # HEAD: the entity-header fields corresponding to the requested resource are sent in the response without any message-body
        # POST: an entity describing or containing the result of the action
        # TRACE: an entity containing the request message as received by the end server.
        OK = 200

        # Resource has been fully created
        # URI of resource is in the Location header field
        CREATED = 201

        # Request has been accepted but not processed.  Non-committal.
        ACCEPTED = 202

        NONAUTHORITATIVE_INFORMATION = 203

        NO_CONTENT = 204

        RESET_CONTENT = 205

        PARTIAL_CONTENT = 206
      end

      class Redirection
        MULTIPLE_CHOICES = 300

        MOVED_PERMANENTLY = 301

        FOUND = 302

        SEE_OTHER = 303

        NOT_MODIFIED = 304

        USE_PROXY = 305

        #SWITCH_PROXY = 306

        TEMPORARY_REDIRECT = 307
      end
    end

  end

  class Processor
    def call(env, response)

    end
  end

  class PreProcessor < Processor
    def call(env, response)

    end
  end

  class PostProcessor < Processor
    def call(env, response)

    end
  end
end

class MyNilRouter < Modulo::Router
  def call(env, response)
    nil
  end
end

class Application
  def prepare(env, response)
    @env = env
    @response = response
  end

  def status(value=nil)
    value.nil? ? @response[:status] : @response[:status] = value
  end

  def display(arguments)
    arguments
  end
end

class MyNonNilRouter < Modulo::Router
  def initialize(app)
    @app = app
  end

  def call(env, response)
    @app.prepare(env, response)
    path_info = env['PATH_INFO'].split('/')[1..-1]
    query_string = env['QUERY_STRING']

    @path_info = path_info
    @query_string = query_string
    @arguments = {
      :get => query_string.split('&').inject({}) {|memo, pair| k,v = pair.split('='); memo[k] = v; memo}
    }
    response[:body] << @app.display('foo')
  end
end

class MyProcessor < Modulo::Processor
  def call(env, response)
    #    response[:body].last += " !!!"
    response[:body].push("!foo!")
  end
end

class MyPostProcessor2 < Modulo::Processor
  def call(env, response)
    response[:body].push(" ???")
  end
end

class TimerProcessor < Modulo::Processor
  def call(env, response)
    if(!response[:metadata].key? :time)
      response[:metadata][:time] = Time.now
    else
      puts "Response time: " + (Time.now - response[:metadata][:time]).to_s + "s"
      response[:metadata][:time] = Time.now
    end

  end
end

pipeline = [t = TimerProcessor.new, MyProcessor.new, MyNilRouter.new,
  MyNonNilRouter.new(Application.new), MyProcessor.new, MyPostProcessor2.new,
  t]
puts pipeline.inspect
Rack::Handler::Mongrel.run Modulo::RackApp.new(pipeline), :Port => 1337