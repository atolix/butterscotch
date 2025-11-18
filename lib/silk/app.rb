# frozen_string_literal: true

require 'rack'

require_relative 'routing_dsl'
require_relative 'error_handlers'

module Silk
  # Rack-compatible application that wires the router,
  # runs handlers, and applies error/HEAD handling.
  class App
    include RoutingDSL
    include ErrorHandlers
    attr_reader :router

    def initialize
      @router = Router.new
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
      env['silk.error'] = e
          response = handle_error(e, env, params)
        end
      else
        response = respond_not_found(env)
      end

      return Response.to_head_response(response) if method == 'HEAD'

      response
    end

    def run
      require_relative 'cli'
      Silk::CLI.app = self
      self
    end
  end
end
