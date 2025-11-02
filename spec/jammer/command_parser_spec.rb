# frozen_string_literal: true

require 'spec_helper'

describe Jammer::CommandParser do
  context 'keyword checking options' do
    it 'parses keyword option' do
      parser = Jammer::CommandParser.new(['--keyword', '#FIXME'])
      options = parser.parse

      expect(options[:keyword]).to eq('#FIXME')
    end

    it 'parses short keyword option' do
      parser = Jammer::CommandParser.new(['-a', '#FIXME'])
      options = parser.parse

      expect(options[:keyword]).to eq('#FIXME')
    end

    it 'parses list action' do
      parser = Jammer::CommandParser.new(['--list'])
      options = parser.parse

      expect(options[:action]).to eq(:list)
    end

    it 'parses short list option' do
      parser = Jammer::CommandParser.new(['-l'])
      options = parser.parse

      expect(options[:action]).to eq(:list)
    end

    it 'parses count action' do
      parser = Jammer::CommandParser.new(['--count'])
      options = parser.parse

      expect(options[:action]).to eq(:count)
    end

    it 'parses short count option' do
      parser = Jammer::CommandParser.new(['-c'])
      options = parser.parse

      expect(options[:action]).to eq(:count)
    end
  end

  context 'setup options' do
    it 'parses init action' do
      parser = Jammer::CommandParser.new(['--init'])
      options = parser.parse

      expect(options[:action]).to eq(:init)
    end

    it 'parses uninstall action' do
      parser = Jammer::CommandParser.new(['--uninstall'])
      options = parser.parse

      expect(options[:action]).to eq(:uninstall)
    end

    it 'parses force flag' do
      parser = Jammer::CommandParser.new(['--init', '--force'])
      options = parser.parse

      expect(options[:force]).to be true
    end

    it 'parses short force flag' do
      parser = Jammer::CommandParser.new(['-f'])
      options = parser.parse

      expect(options[:force]).to be true
    end
  end

  context 'other options' do
    it 'parses help action' do
      parser = Jammer::CommandParser.new(['--help'])
      options = parser.parse

      expect(options[:action]).to eq(:help)
    end

    it 'parses short help option' do
      parser = Jammer::CommandParser.new(['-h'])
      options = parser.parse

      expect(options[:action]).to eq(:help)
    end

    it 'parses version action' do
      parser = Jammer::CommandParser.new(['--version'])
      options = parser.parse

      expect(options[:action]).to eq(:version)
    end

    it 'parses short version option' do
      parser = Jammer::CommandParser.new(['-v'])
      options = parser.parse

      expect(options[:action]).to eq(:version)
    end
  end

  context 'combined options' do
    it 'parses multiple options together' do
      parser = Jammer::CommandParser.new(['--init', '--force', '--keyword', '#TODO'])
      options = parser.parse

      expect(options[:action]).to eq(:init)
      expect(options[:force]).to be true
      expect(options[:keyword]).to eq('#TODO')
    end

    it 'returns empty options when no arguments' do
      parser = Jammer::CommandParser.new([])
      options = parser.parse

      expect(options).to be_empty
    end
  end

  context 'error handling' do
    it 'raises ConfigError for invalid option' do
      parser = Jammer::CommandParser.new(['--invalid-option'])
      expect { parser.parse }.to raise_error(Jammer::ConfigError)
    end

    it 'includes parser info in error message' do
      parser = Jammer::CommandParser.new(['--invalid'])
      expect { parser.parse }.to raise_error(Jammer::ConfigError, /Usage: jammer/)
    end
  end

  context 'parser object' do
    it 'returns a valid OptionParser object' do
      parser = Jammer::CommandParser.new
      expect(parser.parser).to be_a(OptionParser)
    end

    it 'can generate help text' do
      parser = Jammer::CommandParser.new
      help_text = parser.parser.to_s

      expect(help_text).to include('Usage: jammer')
      expect(help_text).to include('--keyword')
      expect(help_text).to include('--init')
    end
  end
end