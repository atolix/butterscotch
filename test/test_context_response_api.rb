# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestContextResponseApi < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  def test_status_and_header_are_applied
    app = Silk::App.new
    app.get '/x' do |context|
      context.status 201
      context.header 'X-Foo', 'bar'
      context.text 'ok'
    end
    res = rack(app).get('/x')
    assert_equal 201, res.status
    assert_equal 'bar', res['X-Foo']
    assert_equal 'ok', res.body
  end

  def test_headers_bulk_merge
    app = Silk::App.new
    app.get '/y' do |context|
      context.headers 'X-A' => '1', 'X-B' => '2'
      context.json({ ok: true })
    end
    res = rack(app).get('/y')
    assert_equal '1', res['X-A']
    assert_equal '2', res['X-B']
    assert_equal '{"ok":true}', res.body
  end

  def test_redirect_helper
    app = Silk::App.new
    app.get '/r' do |context|
      context.redirect '/dest'
    end
    res = rack(app).get('/r')
    assert_equal 302, res.status
    assert_equal '/dest', res['Location']
    assert_equal '', res.body
  end

  def test_halt_stops_and_returns_given_status_and_body
    app = Silk::App.new
    app.get '/h' do |context|
      context.halt 418, 'nope', headers: { 'X-Stop' => '1' }
      context.text 'unreachable'
    end
    res = rack(app).get('/h')
    assert_equal 418, res.status
    assert_equal '1', res['X-Stop']
    assert_equal 'nope', res.body
  end

  def test_request_header_reader
    app = Silk::App.new
    app.get '/hdr' do |context|
      v = context.request_header('HTTP_X_TEST')
      context.text(v.to_s)
    end
    res = rack(app).get('/hdr', 'HTTP_X_TEST' => 'abc')
    assert_equal 'abc', res.body
  end
end
