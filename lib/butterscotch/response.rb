# frozen_string_literal: true

module Butterscotch
  # Response helpers for normalizing handler return values,
  # building common responses, and adapting to HEAD.
  module Response
    module_function

    def normalize(result)
      # Allow handlers to return a Rack response or a simple String
      if result.is_a?(Array) && result.size == 3
        status, headers, body = result
        [status, canonical_headers(headers), body]
      elsif result.is_a?(String)
        [200, { 'content-type' => 'text/plain; charset=utf-8' }, [result]]
      elsif result.respond_to?(:to_s)
        [200, { 'content-type' => 'text/plain; charset=utf-8' }, [result.to_s]]
      else
        [204, {}, []]
      end
    end

    def not_found
      [404, { 'content-type' => 'text/plain; charset=utf-8' }, ['Not Found']]
    end

    def error
      [500, { 'content-type' => 'text/plain; charset=utf-8' }, ['Internal Server Error']]
    end

    def to_head_response(response)
      status, headers, body = response
      headers = canonical_headers(headers).dup
      unless headers.key?('content-length') || headers.key?('Content-Length')
        length = body_length(body)
        headers['content-length'] = length.to_s if length
      end
      [status, headers, []]
    end

    def canonical_headers(headers)
      return {} if headers.nil?
      newh = {}
      headers.each { |k, v| newh[k.to_s.downcase] = v }
      newh
    end

    # rubocop:disable Metrics/MethodLength
    def body_length(body)
      return nil unless body.respond_to?(:each)

      total = 0
      begin
        body.each do |chunk|
          next unless chunk.is_a?(String)

          total += chunk.bytesize
        end
      rescue StandardError
        return nil
      end
      total
    end
    # rubocop:enable Metrics/MethodLength
  end
end
