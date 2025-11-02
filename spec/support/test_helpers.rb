# frozen_string_literal: true

module TestHelpers
  # Create a temporary directory with git
  def create_test_git_repo
    test_dir = Dir.mktmpdir('jammer-test-')
    Dir.chdir(test_dir) do
      `git init --initial-branch=main`
      `git config user.email "test@example.com"`
      `git config user.name "Test User"`
      yield test_dir if block_given?
    end
  ensure
    FileUtils.rm_rf(test_dir) if test_dir && Dir.exist?(test_dir)
  end

  # Create a temporary non-git directory
  def create_test_directory
    test_dir = Dir.mktmpdir('jammer-test-')
    Dir.chdir(test_dir) do
      yield test_dir if block_given?
    end
  ensure
    FileUtils.rm_rf(test_dir) if test_dir && Dir.exist?(test_dir)
  end

  # Create a file with specific content
  def create_file(path, content = '')
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    File.write(path, content)
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end