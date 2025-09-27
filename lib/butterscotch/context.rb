# frozen_string_literal: true

require 'json'
require 'rack'

module Butterscotch
  class Context
    attr_reader :req, :params

    def initialize(env, params = {})
      @env = env
      @req = Rack::Request.new(env)
      @params = params
    end

    def ip
      @req.ip
    end

    def header(name)
      @req.get_header(name)
    end

    def set_header(key, value)
      [200, { key => value }, []]
    end

    def text(body, status: 200, headers: {})
      headers = { 'Content-Type' => 'text/plain; charset=utf-8' }.merge(headers)
      [status, headers, [body.to_s]]
    end

    def html(body, status: 200, headers: {})
      headers = { 'Content-Type' => 'text/html; charset=utf-8' }.merge(headers)
      [status, headers, [body.to_s]]
    end

    def json(obj = nil, status: 200, headers: {}, **keyword)
      payload = if obj.nil?
                  keyword.empty? ? {} : keyword
                else
                  obj
                end
      headers = { 'Content-Type' => 'application/json; charset=utf-8' }.merge(headers)
      [status, headers, [JSON.generate(payload)]]
    end
  end
end
