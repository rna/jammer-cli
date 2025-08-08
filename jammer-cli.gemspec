# frozen_string_literal: true

require_relative 'lib/jammer/version'

Gem::Specification.new do |spec|
  spec.name          = "jammer-cli"
  spec.version       = Jammer::VERSION
  spec.authors       = ["Ramesh Naidu Allu"]
  spec.email         = ["im@rna.me"]

  spec.summary       = "A CLI tool to prevent Git commits/pushes with specific keywords."
  spec.description   = "Checks staged files for keywords like TODO/FIXME before commit/push and aborts if found."
  spec.homepage      = "https://github.com/rna/jammer-cli"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

 
  spec.files         = Dir.glob('{lib,bin}/**/*') + %w[LICENSE README.md jammer-cli.gemspec]
 
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end 