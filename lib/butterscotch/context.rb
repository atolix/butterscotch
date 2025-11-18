# frozen_string_literal: true

require 'json'
require 'rack'

module Butterscotch
  # Per-request context: wraps Rack::Request and route params,
  # and provides helpers to build responses.
  class Context
    attr_reader :req, :params

    def initialize(env, params = {})
      @env = env
      @req = Rack::Request.new(env)
      @params = params
      @status = 200
      @resp_headers = {}
    end

    def ip
      @req.ip
    end

    # Request header getter
    def request_header(name)
      @req.get_header(name)
    end

    # Response status getter/setter
    def status(code = nil)
      @status = Integer(code) if code
      @status
    end

    # Response header getter/setter
    def header(key, value = nil)
      return @resp_headers[key.to_s.downcase] if value.nil?

      @resp_headers[key.to_s.downcase] = value
      self
    end

    # Response headers bulk merge or accessor
    def headers(hash = nil)
      @resp_headers.merge!(hash.transform_keys { |k| k.to_s.downcase }) if hash
      @resp_headers
    end

    def text(body, status: nil, headers: {})
      effective_status = status || @status
      effective_headers = {
        'content-type' => 'text/plain; charset=utf-8'
      }.merge(@resp_headers).merge(downcase_keys(headers))
      [effective_status, effective_headers, [body.to_s]]
    end

    def html(body, status: nil, headers: {})
      effective_status = status || @status
      effective_headers = {
        'content-type' => 'text/html; charset=utf-8'
      }.merge(@resp_headers).merge(downcase_keys(headers))
      [effective_status, effective_headers, [body.to_s]]
    end

    def json(obj = nil, status: nil, headers: {}, **keyword)
      payload = if obj.nil?
                  keyword.empty? ? {} : keyword
                else
                  obj
                end
      effective_status = status || @status
      effective_headers = {
        'content-type' => 'application/json; charset=utf-8'
      }.merge(@resp_headers).merge(downcase_keys(headers))
      [effective_status, effective_headers, [JSON.generate(payload)]]
    end

    # Redirect helper (defaults to 302)
    def redirect(location, status: 302, headers: {})
      @status = Integer(status)
      header('location', location)
      @resp_headers.merge!(downcase_keys(headers))
      [@status, @resp_headers.dup, []]
    end

    # Halt immediately with given status/body/headers
    def halt(code = nil, body = nil, headers: {})
      final_status = Integer(code || @status)
      merged_headers = @resp_headers.merge(downcase_keys(headers))
      raise Halt.new(status: final_status, headers: merged_headers, body: body)
    end

    private

    def downcase_keys(hash)
      hash.transform_keys { |k| k.to_s.downcase }
    end
  end
end
