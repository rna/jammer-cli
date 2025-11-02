# frozen_string_literal: true

# Resolves paths to gem resources
module Jammer
  class PathResolver
    def self.hook_template_path
      File.join(gem_root, "hooks", "pre-commit")
    end

    def self.config_example_path
      File.join(gem_root, ".jammer.yml.example")
    end

    def self.hook_path
      return nil unless Git.inside_work_tree?

      require "open3"
      stdout, _stderr, status = Open3.capture3("git", "rev-parse", "--git-dir")
      raise GitError, "Failed to get git directory" unless status.success?

      git_dir = stdout.strip
      File.join(git_dir, "hooks", "pre-commit")
    end

    def self.config_path
      File.join(Dir.pwd, ".jammer.yml")
    end

    def self.gem_root
      gem_spec = Gem.loaded_specs["jammer-cli"]
      raise HookError, "jammer-cli gem specification not found" unless gem_spec

      gem_spec.full_gem_path
    end
  end
end
