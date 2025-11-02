# frozen_string_literal: true

require 'spec_helper'

describe Jammer::Scanner do
  context 'input validation' do
    it 'accepts a single keyword as string' do
      scanner = Jammer::Scanner.new('#TODO')
      expect(scanner.keywords).to eq(['#TODO'])
    end

    it 'accepts multiple keywords as array' do
      keywords = ['#TODO', '#FIXME', '#DEBUG']
      scanner = Jammer::Scanner.new(keywords)
      expect(scanner.keywords).to eq(keywords)
    end

    it 'accepts exclude patterns' do
      exclude = ['vendor/', 'node_modules/']
      scanner = Jammer::Scanner.new('#TODO', exclude)
      expect(scanner.exclude_patterns).to eq(exclude)
    end

    it 'converts single string to array' do
      scanner = Jammer::Scanner.new('TODO')
      scanner.keywords = '#FIXME'
      expect(scanner.keywords).to eq(['#FIXME'])
    end
  end

  context 'error handling' do
    it 'raises ScannerError for empty keyword' do
      expect { Jammer::Scanner.new('') }.to raise_error(Jammer::ScannerError)
    end

    it 'validates all keywords' do
      scanner = Jammer::Scanner.new('#TODO')
      expect { scanner.keywords = ['#TODO', ''] }.to raise_error(Jammer::ScannerError)
    end

    it 'raises ScannerError for whitespace-only keyword' do
      expect { Jammer::Scanner.new('   ') }.to raise_error(Jammer::ScannerError)
    end

    it 'raises ScannerError for keyword exceeding 100 characters' do
      long_keyword = '#' + 'A' * 101
      expect { Jammer::Scanner.new(long_keyword) }.to raise_error(Jammer::ScannerError)
    end

    it 'raises error for keyword exceeding 100 characters' do
      scanner = Jammer::Scanner.new('#TODO')
      long_keyword = '#' + 'A' * 101
      expect { scanner.keyword = long_keyword }.to raise_error(Jammer::ScannerError)
    end
  end

  context 'in a git repository' do
    it 'returns true if keywords are found' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "def hello\n  #TODO: implement\nend")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO')
        expect(scanner.exists?).to be true
      end
    end

    it 'returns false if no keywords are found' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "def hello\n  puts 'hello'\nend")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO')
        expect(scanner.exists?).to be false
      end
    end

    it 'respects exclude patterns' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "def hello\n  #TODO: implement\nend")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO', ['app.rb'])
        expect(scanner.exists?).to be false
      end
    end

    it 'returns formatted list of matches with file and line number' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "line 1\n#TODO: fix this\nline 3")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO')
        list = scanner.occurrence_list

        expect(list).to include('app.rb')
        expect(list).to include('#TODO: fix this')
      end
    end

    it 'returns empty string if no matches found' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "def hello\n  puts 'hello'\nend")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO')
        expect(scanner.occurrence_list).to eq('')
      end
    end
  end

  context 'outside a git repository' do
    it 'searches with grep instead of git grep' do
      create_test_directory do |test_dir|
        create_file('app.rb', "def hello\n  #TODO: implement\nend")

        scanner = Jammer::Scanner.new('#TODO')
        expect(scanner.exists?).to be true
      end
    end
  end

  context 'exclude patterns filtering' do
    it 'filters results by single exclude pattern' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "#TODO: fix")
        create_file('vendor/gem.rb', "#TODO: fix gem")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO', ['vendor/'])
        expect(scanner.occurrence_count).to eq(1)
        expect(scanner.occurrence_list).to include('app.rb')
        expect(scanner.occurrence_list).not_to include('vendor/')
      end
    end

    it 'filters results by multiple exclude patterns' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "#TODO: fix")
        create_file('vendor/gem.rb', "#TODO: fix gem")
        create_file('node_modules/pkg.rb', "#TODO: fix pkg")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO', ['vendor/', 'node_modules/'])
        expect(scanner.occurrence_count).to eq(1)
        expect(scanner.occurrence_list).to include('app.rb')
      end
    end

    it 'handles empty exclude patterns gracefully' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "#TODO: fix")
        `git add .`

        scanner = Jammer::Scanner.new('#TODO', [])
        expect(scanner.occurrence_count).to eq(1)
      end
    end
  end

  context 'multiple keywords' do
    it 'searches for all keywords in single scan' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "#TODO: fix\n#FIXME: also fix\n#DEBUG: debug me")
        `git add .`

        scanner = Jammer::Scanner.new(['#TODO', '#FIXME'])
        expect(scanner.occurrence_count).to eq(2)
      end
    end

    it 'lists all occurrences of multiple keywords' do
      create_test_git_repo do |test_dir|
        create_file('app.rb', "#TODO: fix\n#FIXME: also fix")
        `git add .`

        scanner = Jammer::Scanner.new(['#TODO', '#FIXME'])
        list = scanner.occurrence_list
        expect(list).to include('#TODO')
        expect(list).to include('#FIXME')
      end
    end
  end
end