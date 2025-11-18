# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestHttpMethods < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  def test_post_route
    app = Silk::App.new
    app.post '/submit' do |context|
      context.text 'posted'
    end
    res = rack(app).post('/submit')
    assert_equal 200, res.status
    assert_equal 'posted', res.body
  end

  def test_any_matches_post
    app = Silk::App.new
    app.any '/anything' do |context|
      context.text 'ok'
    end
    res = rack(app).post('/anything')
    assert_equal 200, res.status
    assert_equal 'ok', res.body
  end

  def test_put_route
    app = Silk::App.new
    app.put '/items/1' do |context|
      context.text 'put'
    end
    res = rack(app).put('/items/1')
    assert_equal 200, res.status
    assert_equal 'put', res.body
  end

  def test_patch_route
    app = Silk::App.new
    app.patch '/items/1' do |context|
      context.text 'patch'
    end
    res = rack(app).patch('/items/1')
    assert_equal 200, res.status
    assert_equal 'patch', res.body
  end

  def test_delete_route
    app = Silk::App.new
    app.delete '/items/1' do |context|
      context.text 'deleted'
    end
    res = rack(app).delete('/items/1')
    assert_equal 200, res.status
    assert_equal 'deleted', res.body
  end

  def test_head_uses_get_handler_and_strips_body
    app = Silk::App.new
    app.get '/head' do |context|
      context.text 'hello'
    end
    res = rack(app).head('/head')
    assert_equal 200, res.status
    assert_equal '', res.body
    assert_equal 'text/plain; charset=utf-8', res['Content-Type']
    assert_equal '5', res['Content-Length']
  end
end
