# frozen_string_literal: true

# Resolves paths to gem resources
module Jammer
  class PathResolver
    ROOT_MARKERS = [
      [".jammer.yml.example"],
      ["hooks", "pre-commit"]
    ].freeze

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
      return gem_spec.full_gem_path if gem_spec

      source_root = File.expand_path("../..", __dir__)
      return source_root if root_markers_present?(source_root)

      raise HookError, "Could not resolve jammer-cli root path"
    end

    def self.root_markers_present?(root)
      ROOT_MARKERS.all? { |parts| File.exist?(File.join(root, *parts)) }
    end
    private_class_method :root_markers_present?
  end
end
