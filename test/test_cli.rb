# frozen_string_literal: true

require 'test_helper'
require 'butterscotch/cli'
require 'tmpdir'

class TestCLI < Minitest::Test
  def test_default_port_is_3000
    original_port = ENV.delete('PORT')
    defaults = Butterscotch::CLI.default_options
    assert_equal 3000, defaults[:port]
  ensure
    ENV['PORT'] = original_port if original_port
  end

  def test_loads_app_from_main_by_default
    Dir.mktmpdir do |dir|
      lib_path = File.expand_path('../lib', __dir__)
      File.write(File.join(dir, 'main.rb'), <<~RUBY)
        $LOAD_PATH.unshift("#{lib_path}") unless $LOAD_PATH.include?("#{lib_path}")
        require 'butterscotch'

        app = Butterscotch.new
        Butterscotch::CLI.app = app
      RUBY

      original_app = Butterscotch::CLI.app
      Dir.chdir(dir) do
        Butterscotch::CLI.app = nil
        app = Butterscotch::CLI.resolve_app(Butterscotch::CLI.default_options)
        assert_instance_of Butterscotch::App, app
      end
      Butterscotch::CLI.app = original_app
    end
  end

  def test_app_run_assigns_cli_app
    original_app = Butterscotch::CLI.app
    app = Butterscotch::App.new
    Butterscotch::CLI.app = nil
    app.run
    assert_equal app, Butterscotch::CLI.app
  ensure
    Butterscotch::CLI.app = original_app
  end
end
