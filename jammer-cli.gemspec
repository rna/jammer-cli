# frozen_string_literal: true

require_relative "lib/jammer/version"

Gem::Specification.new do |spec|
  spec.name          = "jammer-cli"
  spec.version       = Jammer::VERSION
  spec.authors       = ["Ramesh Naidu Allu"]
  spec.email         = ["im@rna.me"]

  spec.summary       = "A CLI tool to block commits containing forbidden keywords."
  spec.description   = "Checks staged files for keywords like TODO/FIXME " \
                       "before commit and aborts when matches are found."
  spec.homepage      = "https://github.com/rna/jammer-cli"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1")

  spec.files = Dir.chdir(__dir__) do
    runtime_files = Dir.glob("{bin,hooks,lib}/**/*").select { |path| File.file?(path) }
    docs_files = %w[README.md CHANGELOG.md CONTRIBUTING.md LICENSE .jammer.yml.example]
    (runtime_files + docs_files).sort
  end

  spec.executables   = ["jammer"]
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
end
