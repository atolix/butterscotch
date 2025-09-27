# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

class TestHandlerObjects < Minitest::Test
  def rack(app) = Rack::MockRequest.new(app)

  class HelloHandler
    def call(context)
      context.text 'hi'
    end
  end

  class OkHandler
    def call
      'ok'
    end
  end

  class KlassHandler
    def call(context)
      context.json ok: true
    end
  end

  def test_instance_handler_with_context
    app = Butterscotch::App.new
    app.get '/h', HelloHandler.new
    res = rack(app).get('/h')
    assert_equal 200, res.status
    assert_equal 'hi', res.body
  end

  def test_instance_handler_without_context
    app = Butterscotch::App.new
    app.get '/ok', OkHandler.new
    res = rack(app).get('/ok')
    assert_equal 200, res.status
    assert_equal 'ok', res.body
  end

  def test_class_handler_is_instantiated
    app = Butterscotch::App.new
    app.get '/klass', KlassHandler
    res = rack(app).get('/klass')
    assert_equal 200, res.status
    assert_equal '{"ok":true}', res.body
  end

  def test_post_with_handler_object
    app = Butterscotch::App.new
    app.post '/post', HelloHandler.new
    res = rack(app).post('/post')
    assert_equal 200, res.status
    assert_equal 'hi', res.body
  end

  def test_put_with_handler_class
    app = Butterscotch::App.new
    app.put '/put', KlassHandler
    res = rack(app).put('/put')
    assert_equal 200, res.status
    assert_equal '{"ok":true}', res.body
  end

  def test_patch_with_zero_arity_handler
    app = Butterscotch::App.new
    app.patch '/patch', OkHandler.new
    res = rack(app).patch('/patch')
    assert_equal 200, res.status
    assert_equal 'ok', res.body
  end

  def test_delete_with_handler_object
    app = Butterscotch::App.new
    app.delete '/del', HelloHandler.new
    res = rack(app).delete('/del')
    assert_equal 200, res.status
    assert_equal 'hi', res.body
  end

  def test_head_with_handler_object
    app = Butterscotch::App.new
    app.get '/head', HelloHandler.new
    res = rack(app).head('/head')
    assert_equal 200, res.status
    assert_equal '', res.body
    assert_equal 'text/plain; charset=utf-8', res['Content-Type']
  end
end
