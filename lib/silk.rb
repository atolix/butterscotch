# frozen_string_literal: true

require_relative 'silk/version'
require_relative 'silk/context'
require_relative 'silk/router'
require_relative 'silk/routing_dsl'
require_relative 'silk/error_handlers'
require_relative 'silk/halt'
require_relative 'silk/response'
require_relative 'silk/app'

module Silk
  class Error < StandardError; end

  # Convenience constructor: Silk.new => Silk::App
  def self.new
    App.new
  end
end
