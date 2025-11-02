# frozen_string_literal: true

require 'spec_helper'

describe Jammer::CommandExecutor do
  context 'when all commands pass' do
    it 'returns all successful results' do
      executor = Jammer::CommandExecutor.new(['echo "hello"', 'echo "world"'])
      results = executor.run_all

      expect(results.length).to eq(2)
      expect(results.all? { |r| r[:success] }).to be true
    end

    it 'reports all commands passed' do
      executor = Jammer::CommandExecutor.new(['echo "test"'])
      executor.run_all

      expect(executor.all_passed?).to be true
      expect(executor.report).to include('✓ All checks passed')
    end
  end

  context 'when commands fail' do
    it 'captures failed command output' do
      executor = Jammer::CommandExecutor.new(['false'])
      results = executor.run_all

      expect(results.length).to eq(1)
      expect(results.first[:success]).to be false
      expect(results.first[:exit_code]).to eq(1)
    end

    it 'reports failed commands' do
      executor = Jammer::CommandExecutor.new(['false', 'echo "hello"'])
      executor.run_all

      expect(executor.all_passed?).to be false
      expect(executor.failed_results.length).to eq(1)
      expect(executor.report).to include('✗ Some checks failed')
    end

    it 'includes command and exit code in report' do
      executor = Jammer::CommandExecutor.new(['exit 42'])
      executor.run_all

      report = executor.report
      expect(report).to include('exit 42')
      expect(report).to include('Exit code: 42')
    end
  end

  context 'with command output' do
    it 'captures stdout from commands' do
      executor = Jammer::CommandExecutor.new(['echo "test output"'])
      results = executor.run_all

      expect(results.first[:output]).to include('test output')
    end

    it 'includes output in report for failed commands' do
      executor = Jammer::CommandExecutor.new(['echo "error message" && false'])
      executor.run_all

      expect(executor.report).to include('error message')
    end
  end

  context 'with multiple commands' do
    it 'runs all commands in order' do
      executor = Jammer::CommandExecutor.new([
        'echo "first"',
        'echo "second"',
        'echo "third"'
      ])
      results = executor.run_all

      expect(results.length).to eq(3)
      expect(results.all? { |r| r[:success] }).to be true
    end

    it 'runs all commands even if some fail' do
      executor = Jammer::CommandExecutor.new([
        'echo "pass"',
        'exit 1',
        'echo "also runs"'
      ])
      results = executor.run_all

      expect(results.length).to eq(3)
      failed = executor.failed_results
      expect(failed.length).to eq(1)
    end
  end

  context 'with empty commands' do
    it 'handles no commands gracefully' do
      executor = Jammer::CommandExecutor.new([])
      results = executor.run_all

      expect(results).to be_empty
      expect(executor.all_passed?).to be true
    end
  end
end