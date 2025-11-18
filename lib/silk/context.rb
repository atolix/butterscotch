# frozen_string_literal: true

require 'json'
require 'rack'

module Silk
  # Per-request context: wraps Rack::Request and route params,
  # and provides helpers to build responses.
  class Context
    attr_reader :req, :params

    def initialize(env, params = {})
      @env = env
      @req = Rack::Request.new(env)
      @params = params
      @response_state = ResponseState.new
    end

    # Request header getter
    def request_header(name)
      @req.get_header(name)
    end

    # Response status getter/setter
    def status(code = nil)
      @response_state.status(code)
    end

    # Response header getter/setter
    def header(key, value = nil)
      @response_state.header(key, value)
    end

    # Response headers bulk merge or accessor
    def headers(hash = nil)
      @response_state.headers(hash)
    end

    def text(body, status: nil, headers: {})
      @response_state.build_response(body.to_s, status, headers, 'text/plain; charset=utf-8')
    end

    def html(body, status: nil, headers: {})
      @response_state.build_response(body.to_s, status, headers, 'text/html; charset=utf-8')
    end

    def json(body = {}, status: nil, headers: {})
      @response_state.build_response(JSON.generate(body), status, headers, 'application/json; charset=utf-8')
    end

    # Redirect helper (defaults to 302)
    def redirect(location, status: 302, headers: {})
      @response_state.status(status)
      header('location', location)
      headers(headers)
      [@response_state.current_status, @response_state.current_headers, []]
    end

    # Halt immediately with given status/body/headers
    def halt(code = nil, body = nil, headers: {})
      final_status = Integer(code || @response_state.current_status)
      merged_headers = @response_state.current_headers.merge(@response_state.downcase_keys(headers))
      raise Halt.new(status: final_status, headers: merged_headers, body: body)
    end

    private

    def downcase_keys(hash)
      @response_state.downcase_keys(hash)
    end

    # Internal helper to track response status/headers and build responses.
    class ResponseState
      attr_reader :current_status, :current_headers

      def initialize
        @current_status = 200
        @current_headers = {}
      end

      def status(code = nil)
        @current_status = Integer(code) if code
        @current_status
      end

      def header(key, value = nil)
        return @current_headers[key.to_s.downcase] if value.nil?

        @current_headers[key.to_s.downcase] = value
        self
      end

      def headers(hash = nil)
        @current_headers.merge!(downcase_keys(hash)) if hash
        @current_headers
      end

      def build_response(body, status_override, extra_headers, default_content_type)
        effective_status = status_override ? Integer(status_override) : @current_status
        base_headers = { 'content-type' => default_content_type }
        merged = base_headers.merge(@current_headers).merge(downcase_keys(extra_headers))
        [effective_status, merged, [body]]
      end

      def downcase_keys(hash)
        return {} unless hash

        hash.transform_keys { |k| k.to_s.downcase }
      end
    end
  end
end
