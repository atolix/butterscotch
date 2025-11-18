# frozen_string_literal: true

require 'rack'

module Butterscotch
  # Rack-compatible application that wires the router,
  # runs handlers, and applies error/HEAD handling.
  class App
    attr_reader :router

    def initialize
      @router = Router.new
      @error_handlers = {}
      @not_found_handler = nil
    end

    # Rack interface
    def call(env)
      request = Rack::Request.new(env)
      method = request.request_method
      path = request.path_info
      response = nil
      if (found = @router.match(method, path))
        route, params = found
        context = Context.new(env, params)
        begin
          handler = route.handler
          handler = handler.new if handler.is_a?(Class)
          call_arity = begin
            handler.method(:call).arity
          rescue NameError
            0
          end
          result = call_arity.zero? ? handler.call : handler.call(context)
          response = Response.normalize(result)
        rescue Halt => e
          response = [e.status, e.headers, e.body]
        rescue StandardError => e
          env['butterscotch.error'] = e
          response = handle_error(e, env, params)
        end
      else
        response = respond_not_found(env)
      end

      return Response.to_head_response(response) if method == 'HEAD'

      response
    end

    %i[get post put patch delete options head trace].each do |method_name|
      define_method(method_name) do |path, handler = nil, &block|
        @router.add(method_name, path, handler, &block)
      end
    end

    def any(path, &block)
      Router::HTTP_METHODS.each { |m| @router.add(m, path, &block) }
    end

    def group(prefix)
      group = Group.new(self, prefix)
      yield group if block_given?
      group
    end

    def run
      require_relative 'cli'
      Butterscotch::CLI.app = self
      self
    end

    # Register an error handler for a specific exception class (or StandardError by default)
    def error(klass = StandardError, &block)
      raise ArgumentError, 'error handler block required' unless block

      @error_handlers[klass] = block
      self
    end

    # Set a custom 404 handler: app.not_found { |context| ... }
    def not_found(&block)
      raise ArgumentError, 'block required' unless block_given?

      @not_found_handler = block
      self
    end

    # A grouping helper
    class Group
      def initialize(app, prefix)
        @app = app
        @prefix = normalize_prefix(prefix)
      end

      %i[get post put patch delete options head trace any].each do |http_method|
        define_method(http_method) do |path, handler = nil, &block|
          full = join(@prefix, path)
          @app.public_send(http_method, full, handler, &block)
        end
      end

      def group(prefix)
        nested = self.class.new(@app, join(@prefix, prefix))
        yield nested if block_given?
        nested
      end

      private

      def join(prefix, path)
        prefix = '/' if prefix.nil? || prefix.empty?
        path = path.to_s
        return prefix if path.empty? || path == '/'

        (prefix.end_with?('/') ? prefix.chop : prefix) + (path.start_with?('/') ? path : "/#{path}")
      end

      def normalize_prefix(prefix)
        return '/' if prefix.nil? || prefix.empty?

        prefix.start_with?('/') ? prefix : "/#{prefix}"
      end
    end

    private

    def respond_not_found(env)
      if @not_found_handler
        context = Context.new(env, {})
        return Response.normalize(call_block(@not_found_handler, nil, context))
      end
      Response.not_found
    end

    def handle_error(error, env, params)
      handler = find_error_handler(error)
      return default_error(error) unless handler

      context = Context.new(env, params)
      Response.normalize(call_block(handler, error, context))
    end

    def find_error_handler(error)
      error.class.ancestors.each do |klass|
        return @error_handlers[klass] if @error_handlers.key?(klass)
        break if klass == Object
      end
      nil
    end

    def call_block(handler_proc, error, context)
      case handler_proc.arity
      when 2 then handler_proc.call(error, context)
      when 1 then handler_proc.call(context)
      else handler_proc.call
      end
    end

    def default_error(_error)
      Response.error
    end
  end
end
