require 'rubygems'
require 'rack'

module Modulo
  class RackApp
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def call(env)
      request = Rack::Request.new(env)
      Rack::Response.new do |response|
        catch(:halt) do
          @pipeline.each do |stage|
            if(stage.respond_to? :call)
              stage.call(env)
            elsif(stage.respond_to? :process)
              stage.process(request, response)
            end
          end
        end
      end.finish
    end
  end

  class Router
    HTTP_VERBS = ['GET', 'HEAD', 'POST', 'PUT', 'DELETE']
    def initialize(app, &block)
      @map = {}
      HTTP_VERBS.each {|v| @map[v] = {}}

      @app_class = app
      instance_eval(&block) if block_given?
      puts @map.inspect
    end

    def process(request, response)
      app = @app_class.new(request, response)
      response.write("Hi!")
      if(@map[request.env['REQUEST_METHOD']].key? request.path_info)
        method = @map[request.env['REQUEST_METHOD']][request.path_info]
        if(method.is_a? Symbol)
          app.send(method)
        elsif(method.is_a? Proc)
          app.instance_eval(&method)
        end
      end
    end

    def map(verb, path, to)
      @map[verb][path] = to
    end

    def get(path, to=nil, &block)
      if block_given?
        map('GET', path, block)
      else
        map('GET', path, to)
      end
      
    end
  end

  class Processor
    
  end

  class PreProcessor < Processor
    def call(env, response)

    end
  end

  class PostProcessor < Processor
    def call(env, response)

    end
  end

  class Application
    def initialize(request, response)
      @request = request
      @response = response
      @path_info_array = request.env['PATH_INFO'].split('/')[1..-1]
      @query_string = request.env['QUERY_STRING']
    end

    def cat
      @response.write('meow')
    end
  end
end

class MyApplication < Modulo::Application
  def initialize(request, response)
    super
  end
end

class MyRouter < Modulo::Router

end


class TimerProcessor < Modulo::Processor
  def process(request, response)
    request[:metadata] ||= {}
    if(!request[:metadata].key? :time)
      request[:metadata][:time] = Time.now
    else
      puts "Response time: " + (Time.now - request[:metadata][:time]).to_s + "s"
      request[:metadata][:time] = Time.now
    end

  end
end

router = MyRouter.new(MyApplication) do
  get '/foo' do
    puts "found foo"
  end
end

pipeline = [t = TimerProcessor.new, router, t]
Rack::Handler::Mongrel.run Modulo::RackApp.new(pipeline), :Port => 1337