# frozen_string_literal: true

module Butterscotch
  # Control-flow exception used to stop processing and
  # immediately return a specific Rack response.
  class Halt < StandardError
    attr_reader :status, :headers, :body

    def initialize(status:, headers: {}, body: [])
      super("halt: #{status}")
      @status = Integer(status)
      @headers = headers.transform_keys { |k| k.to_s.downcase }
      @body = normalize_body(body)
    end

    private

    def normalize_body(body)
      return body if body.is_a?(Array)
      return [body.to_s] if body

      []
    end
  end
end
