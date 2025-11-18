# frozen_string_literal: true

require 'optparse'

module Butterscotch
  # CLI entrypoint to run Butterscotch apps without rackup.
  # Provides config/appfile loading and server bootstrap.
  module CLI
    class << self
      attr_accessor :app
    end

    def self.start(argv = ARGV)
      options = parse_options(argv)
      ENV['RACK_ENV'] = options[:env]
      app = resolve_app(options)
      run_server(app, options)
    end

    def self.parse_options(argv)
      options = default_options
      parser = build_option_parser(options)
      parser.parse!(argv)
      options
    end

    def self.default_options
      {
        host: ENV.fetch('HOST', '127.0.0.1'),
        port: (ENV['PORT'] || '3000').to_i,
        env: ENV.fetch('RACK_ENV', 'development'),
        config: nil,
        appfile: nil,
        server: 'webrick'
      }
    end

    def self.build_option_parser(options)
      OptionParser.new do |opts|
        configure_banner(opts)
        add_runtime_options(opts, options)
        add_meta_options(opts)
      end
    end

    def self.configure_banner(opts)
      opts.banner = 'Usage: butterscotch [options]'
    end

    def self.add_runtime_options(opts, options)
      opts.on('-o', '--host HOST', 'Bind host (default: 127.0.0.1)') { |host| options[:host] = host }
      opts.on('-p', '--port PORT', Integer, 'Bind port (default: 3000)') { |port| options[:port] = port }
      opts.on('-e', '--env ENV', 'RACK_ENV (default: development)') { |env| options[:env] = env }
      opts.on('-c', '--config FILE', 'Rack config.ru to load') { |file| options[:config] = file }
      opts.on('-f', '--appfile FILE', 'Ruby file that sets Butterscotch::CLI.app') { |file| options[:appfile] = file }
      opts.on('-s', '--server NAME', 'Rack server (default: webrick)') { |name| options[:server] = name }
    end

    def self.add_meta_options(opts)
      opts.on('-v', '--version', 'Print version') do
        puts Butterscotch::VERSION
        exit 0
      end
      opts.on('-h', '--help', 'Show help') do
        puts opts
        exit 0
      end
    end

    def self.resolve_app(options)
      return resolve_from_config(options[:config]) if options[:config] || File.exist?('config.ru')
      return resolve_from_appfile(options[:appfile]) if options[:appfile]

      build_default_app
    end

    def self.resolve_from_config(file)
      file ||= 'config.ru'
      require 'rack'
      if Rack::Builder.respond_to?(:parse_file)
        app, = Rack::Builder.parse_file(file)
        return app
      end
      abort "Cannot load #{file}. Ensure rack is installed."
    rescue LoadError
      abort "Cannot load rack to parse #{file}. Install rack."
    end

    def self.resolve_from_appfile(appfile)
      require File.expand_path(appfile)
      return Butterscotch::CLI.app if Butterscotch::CLI.app

      abort 'App file did not set Butterscotch::CLI.app'
    end

    def self.build_default_app
      default = Butterscotch.new
      default.get('/') { |context| context.text 'butterscotch up' }
      default
    end

    def self.run_server(app, options)
      run_with_rackup(app, options)
    rescue LoadError
      run_with_handler(app, options)
    end

    def self.run_with_rackup(app, options)
      require 'rackup'
      require 'webrick' if options[:server].to_s.downcase == 'webrick'
      Rackup::Server.start(app: app, Host: options[:host], Port: options[:port], server: options[:server].to_sym)
    end

    def self.run_with_handler(app, options)
      require 'rack'
      handler = (Rack::Handler::WEBrick if defined?(Rack::Handler::WEBrick))
      if handler
        handler.run(app, Host: options[:host], Port: options[:port])
      else
        abort 'No server available. Install rackup or a Rack server (e.g., puma, webrick).'
      end
    rescue LoadError
      abort 'Rack not available. Install rack or run via Bundler.'
    end
  end
end
