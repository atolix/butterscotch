# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestRoutingDefinition < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  def test_root_route_text
    app = Butterscotch::App.new
    app.get '/' do |context|
      context.text 'hi'
    end
    res = rack(app).get('/')
    assert_equal 200, res.status
    assert_equal 'hi', res.body
  end

  def test_path_params
    app = Butterscotch::App.new
    app.get '/hello/:name' do |context|
      context.text "Hello, #{context.params['name']}!"
    end
    res = rack(app).get('/hello/Ada')
    assert_equal 200, res.status
    assert_equal 'Hello, Ada!', res.body
  end

  def test_grouping_with_prefix
    app = Butterscotch::App.new
    app.group '/api' do |g|
      g.get '/ping' do |context|
        context.text 'pong'
      end
    end
    res = rack(app).get('/api/ping')
    assert_equal 200, res.status
    assert_equal 'pong', res.body
  end

  def test_not_found_returns_404 # rubocop:disable Naming/VariableNumber
    app = Butterscotch::App.new
    res = rack(app).get('/missing')
    assert_equal 404, res.status
  end
end
