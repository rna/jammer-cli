# frozen_string_literal: true

require 'open3'

module Jammer
  module Git
    def self.inside_work_tree?
      stdout, _stderr, status = Open3.capture3('git', 'rev-parse', '--is-inside-work-tree')
      status.success? && stdout.strip == 'true'
    end
  end
end
