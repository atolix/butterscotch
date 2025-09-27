# frozen_string_literal: true

require_relative 'butterscotch/version'
require_relative 'butterscotch/context'
require_relative 'butterscotch/router'
require_relative 'butterscotch/halt'
require_relative 'butterscotch/response'
require_relative 'butterscotch/app'

# rubocop:disable Style/Documentation
module Butterscotch
  class Error < StandardError; end

  # Convenience constructor: Butterscotch.new => Butterscotch::App
  def self.new
    App.new
  end
end
# rubocop:enable Style/Documentation
