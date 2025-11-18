# frozen_string_literal: true

module Silk
  # Shared helpers for registering and invoking error/not-found handlers.
  module ErrorHandlers
    def error(klass = StandardError, &block)
      raise ArgumentError, 'error handler block required' unless block

      error_handlers[klass] = block
      self
    end

    def not_found(&block)
      raise ArgumentError, 'block required' unless block_given?

      @not_found_handler = block
      self
    end

    private

    def error_handlers
      @error_handlers ||= {}
    end

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
        return error_handlers[klass] if error_handlers.key?(klass)
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
