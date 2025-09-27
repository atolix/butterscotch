# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestErrorHandling < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  def test_default_500_when_no_handler
    app = Butterscotch::App.new
    app.get '/boom' do |_context|
      raise 'fail'
    end
    res = rack(app).get('/boom')
    assert_equal 500, res.status
    assert_equal 'Internal Server Error', res.body
  end

  def test_custom_error_handler_for_standard_error
    app = Butterscotch::App.new
    app.error(StandardError) do |error, context|
      context.json error: error.message
    end
    app.get '/boom' do |_context|
      raise 'bad'
    end
    res = rack(app).get('/boom')
    assert_equal 200, res.status
    assert_equal '{"error":"bad"}', res.body
  end

  def test_more_specific_handler_is_chosen
    app = Butterscotch::App.new
    app.error(StandardError) { |error, context| context.text "std: #{error.class}" }
    app.error(ArgumentError) { |error, context| context.text "arg: #{error.class}" }
    app.get '/boom' do |_context|
      raise ArgumentError, 'x'
    end
    res = rack(app).get('/boom')
    assert_equal 200, res.status
    assert_match(/^arg: ArgumentError$/, res.body)
  end

  def test_custom_not_found_handler
    app = Butterscotch::App.new
    app.not_found { |context| context.text 'nah' }
    res = rack(app).get('/missing')
    assert_equal 200, res.status
    assert_equal 'nah', res.body
  end
end
