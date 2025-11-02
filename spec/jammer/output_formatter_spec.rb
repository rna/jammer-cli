# frozen_string_literal: true

require 'spec_helper'

describe Jammer::OutputFormatter do
  context 'version output' do
    it 'returns version string' do
      output = Jammer::OutputFormatter.version
      expect(output).to match(/Jammer version \d+\.\d+\.\d+/)
    end
  end

  context 'help output' do
    it 'returns help text from parser' do
      parser = double('parser', to_s: 'help text')
      output = Jammer::OutputFormatter.help(parser)
      expect(output).to eq('help text')
    end
  end

  context 'keyword checking outputs' do
    it 'formats keywords found message' do
      output = Jammer::OutputFormatter.keywords_found(['#TODO', '#FIXME'])
      expect(output).to include('Found keywords')
      expect(output).to include('#TODO')
      expect(output).to include('#FIXME')
      expect(output).to include('Aborting commit')
    end

    it 'formats single keyword' do
      output = Jammer::OutputFormatter.keywords_found(['#TODO'])
      expect(output).to include('#TODO')
    end
  end

  context 'initialization outputs' do
    it 'returns config created message' do
      output = Jammer::OutputFormatter.config_created
      expect(output).to include('Created')
      expect(output).to include('.jammer.yml')
    end

    it 'returns config already exists message' do
      output = Jammer::OutputFormatter.config_already_exists
      expect(output).to include('already exists')
    end

    it 'returns hook created message' do
      output = Jammer::OutputFormatter.hook_created
      expect(output).to include('hook')
      expect(output).to include('installed')
    end

    it 'returns hook already exists message' do
      output = Jammer::OutputFormatter.hook_already_exists
      expect(output).to include('hook')
      expect(output).to include('already exists')
    end

    it 'returns not in git repo message' do
      output = Jammer::OutputFormatter.not_in_git_repo
      expect(output).to include('Git repository')
      expect(output).to include('jammer --init')
    end
  end

  context 'uninstall outputs' do
    it 'returns config removed message' do
      output = Jammer::OutputFormatter.config_removed
      expect(output).to include('Removed')
      expect(output).to include('.jammer.yml')
    end

    it 'returns hook removed message' do
      output = Jammer::OutputFormatter.hook_removed
      expect(output).to include('Removed')
      expect(output).to include('hook')
    end

    it 'returns uninstall complete message' do
      output = Jammer::OutputFormatter.uninstall_complete
      expect(output).to include('uninstalled')
    end
  end

  context 'error outputs' do
    it 'formats error message' do
      output = Jammer::OutputFormatter.error('Something went wrong')
      expect(output).to include('error')
      expect(output).to include('Something went wrong')
    end

    it 'preserves error details' do
      error_detail = 'File not found'
      output = Jammer::OutputFormatter.error(error_detail)
      expect(output).to include(error_detail)
    end
  end

  context 'output consistency' do
    it 'all methods return strings' do
      expect(Jammer::OutputFormatter.version).to be_a(String)
      expect(Jammer::OutputFormatter.config_created).to be_a(String)
      expect(Jammer::OutputFormatter.keywords_found(['#TODO'])).to be_a(String)
      expect(Jammer::OutputFormatter.error('test')).to be_a(String)
    end

    it 'all public methods are callable' do
      expect(Jammer::OutputFormatter).to respond_to(:version)
      expect(Jammer::OutputFormatter).to respond_to(:help)
      expect(Jammer::OutputFormatter).to respond_to(:keywords_found)
      expect(Jammer::OutputFormatter).to respond_to(:config_created)
      expect(Jammer::OutputFormatter).to respond_to(:config_already_exists)
      expect(Jammer::OutputFormatter).to respond_to(:hook_created)
      expect(Jammer::OutputFormatter).to respond_to(:hook_already_exists)
      expect(Jammer::OutputFormatter).to respond_to(:not_in_git_repo)
      expect(Jammer::OutputFormatter).to respond_to(:config_removed)
      expect(Jammer::OutputFormatter).to respond_to(:hook_removed)
      expect(Jammer::OutputFormatter).to respond_to(:uninstall_complete)
      expect(Jammer::OutputFormatter).to respond_to(:error)
    end
  end
end