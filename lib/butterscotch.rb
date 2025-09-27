# frozen_string_literal: true

require_relative 'butterscotch/version'
require_relative 'butterscotch/context'
require_relative 'butterscotch/router'
require_relative 'butterscotch/app'

module Butterscotch
  class Error < StandardError; end

  # Convenience constructor: Butterscotch.new => Butterscotch::App
  def self.new
    App.new
  end
end
