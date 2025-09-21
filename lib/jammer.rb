# frozen_string_literal: true

require_relative 'jammer/version'
require_relative 'jammer/git'
require_relative 'jammer/hook_manager'
require_relative 'jammer/scanner'
require_relative 'jammer/command_line_interface'

module Jammer
  class Error < StandardError; end
end
