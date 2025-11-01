# frozen_string_literal: true

require_relative 'jammer/version'
require_relative 'jammer/config'
require_relative 'jammer/git'
require_relative 'jammer/hook_manager'
require_relative 'jammer/scanner'
require_relative 'jammer/command_line_interface'

module Jammer
  class Error < StandardError; end
  class ConfigError < Error; end
  class GitError < Error; end
  class HookError < Error; end
  class ScannerError < Error; end
end
