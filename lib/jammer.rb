# frozen_string_literal: true

require_relative 'jammer/version'
require_relative 'jammer/config'
require_relative 'jammer/git'
require_relative 'jammer/path_resolver'
require_relative 'jammer/config_manager'
require_relative 'jammer/hook_manager'
require_relative 'jammer/search_tool'
require_relative 'jammer/git_grep_tool'
require_relative 'jammer/grep_tool'
require_relative 'jammer/scanner'
require_relative 'jammer/command_executor'
require_relative 'jammer/command_parser'
require_relative 'jammer/output_formatter'
require_relative 'jammer/command_line_interface'

module Jammer
  class Error < StandardError; end
  class ConfigError < Error; end
  class GitError < Error; end
  class HookError < Error; end
  class ScannerError < Error; end
end
