# frozen_string_literal: true

module Butterscotch
  # Shared routing helpers used by App and nested groups.
  module RoutingDSL
    ROUTE_METHODS = %i[get post put patch delete options head trace].freeze

    ROUTE_METHODS.each do |http_method|
      define_method(http_method) do |path, handler = nil, &block|
        router.add(http_method, path, handler, &block)
      end
    end

    def any(path, &block)
      Router::HTTP_METHODS.each { |method_name| router.add(method_name, path, &block) }
    end

    def group(prefix)
      group = Group.new(self, prefix)
      yield group if block_given?
      group
    end

    # Nested grouping helper with prefixed routes.
    class Group
      def initialize(app, prefix)
        @app = app
        @prefix = normalize_prefix(prefix)
      end

      ROUTE_METHODS.each do |http_method|
        define_method(http_method) do |path, handler = nil, &block|
          @app.router.add(http_method, join(@prefix, path), handler, &block)
        end
      end

      def any(path, &block)
        full = join(@prefix, path)
        Router::HTTP_METHODS.each { |method_name| @app.router.add(method_name, full, &block) }
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
  end
end
