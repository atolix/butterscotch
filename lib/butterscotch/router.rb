# frozen_string_literal: true

module Butterscotch
  Route = Struct.new(:method, :pattern, :keys, :handler)

  class Router
    HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS TRACE].freeze

    def initialize
      @routes = Hash.new { |h, k| h[k] = [] }
    end

    def add(method, path, &handler)
      raise ArgumentError, 'handler block required' unless handler

      method = normalize_method(method)
      pattern, keys = compile(path)
      @routes[method] << Route.new(method, pattern, keys, handler)
      self
    end

    def match(method, path)
      method = normalize_method(method)
      candidates = @routes[method]
      candidates.each do |route|
        match_data = route.pattern.match(path)
        next unless match_data

        params = {}
        route.keys.each do |key|
          params[key] = match_data[key] if match_data.names.include?(key)
        end
        return [route, params]
      end
      nil
    end

    private

    def normalize_method(method)
      method = method.to_s.upcase
      method = 'GET' if method == 'HEAD' # treat HEAD like GET for matching
      method
    end

    # Convert path patterns like "/users/:id/books/:book_id" to regex
    # Supports:
    #  - :name   => single segment [^/]+
    #  - *splat  => greedy match .*
    #  - trailing slash tolerance
    def compile(path)
      raise ArgumentError, 'path must start with /' unless path.start_with?('/')

      keys = []
      pattern = path.split('/').map do |seg|
        case seg
        when ''
          ''
        when '*'
          keys << 'splat'
          '(?<splat>.*)'
        when /^:(\w+)$/
          key = Regexp.last_match(1)
          keys << key
          "(?<#{key}>[^/]+)"
        else
          Regexp.escape(seg)
        end
      end.join('/')

      [%r{^#{pattern}/?$}, keys]
    end
  end
end
