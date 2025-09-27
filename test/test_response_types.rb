# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestResponseTypes < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  def test_text_helper
    app = Butterscotch::App.new
    app.get '/' do |context|
      context.text 'ok'
    end
    res = rack(app).get('/')
    assert_equal 200, res.status
    assert_equal 'text/plain; charset=utf-8', res['Content-Type']
    assert_equal 'ok', res.body
  end

  def test_json_helper
    app = Butterscotch::App.new
    app.get '/json' do |context|
      context.json ok: true
    end
    res = rack(app).get('/json')
    assert_equal 200, res.status
    assert_equal 'application/json; charset=utf-8', res['Content-Type']
    assert_equal '{"ok":true}', res.body
  end

  def test_plain_string_return_normalized
    app = Butterscotch::App.new
    app.get '/plain' do
      'ok'
    end
    res = rack(app).get('/plain')
    assert_equal 200, res.status
    assert_equal 'ok', res.body
  end
end
