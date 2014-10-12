require 'thin'
require 'webrick'
require 'pry'

module Hack

  class Server

    PORT = 3333
    HOST = 'localhost'

    attr_reader :options

    def self.start
      new(ARGV.first).start
    end

    def initialize(app_path, opts = default_opts)
      @options = opts
      @app = build_app(app_path)
    end

    def start
      server.run(@app, options)
    end

    private

      def server
        @server ||= Hack::Handler.default
      end

      def build_app(app_path)
        ApplikashunKonstructor.parse_file(app_path)
        #Builder.parse_file(app_path)
      end

      def default_opts
        {
          port: PORT,
          host: HOST
        }
      end
  end

  # parses application_file into something usable and runnable, AKA an app!!!
  class ApplikashunKonstructor
    def self.parse_file(somefile)
      config_string = File.read(somefile)
      new_from_string(config_string)
    end

    def self.new_from_string(config_string)
      # We need to eval dat "run(Proc.new { foobar })" junk
      # Needs (A) Not to be just a string and (B) Access to #run
      eval "ApplikashunKonstructor.new {\n" + config_string + "\n}.to_app"
    end

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def run(app)
      @run = app
    end

    def to_app
      @run
    end
  end

  # should never be interfaced with, hence da module
  module Handler
    def self.default
      Hack::Handler::Thin
    end

    # group inputs and instantiate a Thin Server
    # this could be even smaller as thin defaults to localhost:3000
    class Thin
      def self.run(app, options = {})
        host = options[:host]
        port = options[:port]
        args = [host, port, app]
        server = ::Thin::Server.new(*args)
        server.start
      end
    end
  end
end
