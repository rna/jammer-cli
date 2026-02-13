# frozen_string_literal: true

require "spec_helper"
require "stringio"

describe Jammer::CommandLineInterface do
  def run_cli(args)
    cli = described_class.new(args)
    stdout = StringIO.new
    stderr = StringIO.new
    exit_code = nil

    begin
      original_stdout = $stdout
      original_stderr = $stderr
      $stdout = stdout
      $stderr = stderr
      cli.run
    rescue SystemExit => e
      exit_code = e.status
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    [exit_code, stdout.string, stderr.string]
  end

  it "prints a friendly error for invalid config and exits with code 1" do
    create_test_directory do
      create_file(".jammer.yml", "commands: echo test")
      code, _stdout, stderr = run_cli([])

      expect(code).to eq(1)
      expect(stderr).to include("An error occurred")
      expect(stderr).to include("commands")
    end
  end

  it "prints newline-separated init messages outside a git repository" do
    create_test_directory do
      code, stdout, _stderr = run_cli(["--init"])

      expect(code).to eq(0)
      expect(stdout).to include("Created .jammer.yml\nNote: Not in a Git repository")
    end
  end

  it "prints only config removal message when uninstalling outside a git repository" do
    create_test_directory do
      create_file(".jammer.yml", "keywords: [TODO]")
      code, stdout, _stderr = run_cli(["--uninstall"])

      expect(code).to eq(0)
      expect(stdout).to include("Removed .jammer.yml")
      expect(stdout).not_to include("Removed Git pre-commit hook")
      expect(stdout).to include("uninstalled")
    end
  end
end
