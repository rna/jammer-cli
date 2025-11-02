# frozen_string_literal: true

require 'spec_helper'

describe Jammer::PathResolver do
  context 'gem resource paths' do
    it 'returns hook template path' do
      path = Jammer::PathResolver.hook_template_path
      expect(path).to include('hooks')
      expect(path).to include('pre-commit')
      expect(path).to be_a(String)
    end

    it 'returns config example path' do
      path = Jammer::PathResolver.config_example_path
      expect(path).to include('.jammer.yml.example')
      expect(path).to be_a(String)
    end

    it 'both paths include gem root' do
      hook_path = Jammer::PathResolver.hook_template_path
      config_path = Jammer::PathResolver.config_example_path

      expect(hook_path).to include('jammer-cli')
      expect(config_path).to include('jammer-cli')
    end
  end

  context 'project paths' do
    it 'returns config path' do
      path = Jammer::PathResolver.config_path
      expect(path).to include('.jammer.yml')
      expect(path).to include(Dir.pwd)
    end

    it 'returns hook path in git repo' do
      path = Jammer::PathResolver.hook_path
      if Jammer::Git.inside_work_tree?
        expect(path).to include('.git/hooks/pre-commit')
      else
        expect(path).to be_nil
      end
    end

    it 'hook path is nil outside git repo' do
      # This test might return nil if not in a git repo
      # but it should not raise an error
      expect { Jammer::PathResolver.hook_path }.not_to raise_error
    end
  end

  context 'path consistency' do
    it 'hook template path is readable if it exists' do
      path = Jammer::PathResolver.hook_template_path
      # The file should exist as part of the gem
      expect(File.exist?(path)).to be true
    end

    it 'config example path is readable if it exists' do
      path = Jammer::PathResolver.config_example_path
      # The file should exist as part of the gem
      expect(File.exist?(path)).to be true
    end

    it 'all path methods return strings' do
      expect(Jammer::PathResolver.hook_template_path).to be_a(String)
      expect(Jammer::PathResolver.config_example_path).to be_a(String)
      expect(Jammer::PathResolver.config_path).to be_a(String)
    end
  end

  context 'error handling' do
    it 'raises error if gem spec not found' do
      allow(Gem.loaded_specs).to receive(:[]).and_return(nil)
      expect { Jammer::PathResolver.hook_template_path }.to raise_error(Jammer::HookError)
    end
  end
end