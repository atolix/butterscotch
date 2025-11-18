# frozen_string_literal: true

require 'test_helper'
require 'butterscotch/cli'

class TestCLI < Minitest::Test
  def test_default_port_is_3000
    original_port = ENV.delete('PORT')
    defaults = Butterscotch::CLI.default_options
    assert_equal 3000, defaults[:port]
  ensure
    ENV['PORT'] = original_port if original_port
  end
end
