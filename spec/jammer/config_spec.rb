# frozen_string_literal: true

require "spec_helper"

describe Jammer::Config do
  context "when config file exists" do
    it "loads config from current directory" do
      create_test_directory do |test_dir|
        config_content = <<~YAML
          keywords:
            - "#TODO"
            - "#FIXME"
          exclude:
            - "vendor/"
        YAML
        create_file(".jammer.yml", config_content)

        config = Jammer::Config.new(test_dir)
        expect(config.keywords).to eq(["#TODO", "#FIXME"])
        expect(config.exclude).to eq(["vendor/"])
      end
    end

    it "uses default exclude (empty array) if not in config" do
      create_test_directory do |test_dir|
        config_content = <<~YAML
          keywords:
            - "#TODO"
        YAML
        create_file(".jammer.yml", config_content)
        config = Jammer::Config.new(test_dir)
        expect(config.exclude).to eq([])
      end
    end

    it "searches parent directories for config file" do
      create_test_directory do |test_dir|
        config_content = <<~YAML
          keywords:
            - "#CUSTOM"
        YAML
        create_file(".jammer.yml", config_content)
        subdir = File.join(test_dir, "src", "lib")
        FileUtils.mkdir_p(subdir)

        Dir.chdir(subdir) do
          config = Jammer::Config.new(".")
          expect(config.keywords).to eq(["#CUSTOM"])
        end
      end
    end

    it "returns exclude patterns from config" do
      create_test_directory do |test_dir|
        config_content = <<~YAML
          keywords:
            - "#TODO"
          exclude:
            - "vendor/"
            - "node_modules/"
            - ".git/"
        YAML
        create_file(".jammer.yml", config_content)

        config = Jammer::Config.new(test_dir)
        expect(config.exclude).to eq(["vendor/", "node_modules/", ".git/"])
      end
    end
  end

  context "when config file not exists" do
    it "uses default keyword if config file not found" do
      create_test_directory do |test_dir|
        config = Jammer::Config.new(test_dir)
        expect(config.keywords).to eq(["#TODO"])
      end
    end
  end

  context "config validation" do
    it "raises ConfigError when keywords is not an array" do
      create_test_directory do |test_dir|
        create_file(".jammer.yml", "keywords: TODO")
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /keywords/)
      end
    end

    it "raises ConfigError when exclude is not an array" do
      create_test_directory do |test_dir|
        create_file(".jammer.yml", "exclude: vendor/")
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /exclude/)
      end
    end

    it "raises ConfigError when commands is not an array" do
      create_test_directory do |test_dir|
        create_file(".jammer.yml", "commands: echo test")
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /commands/)
      end
    end

    it "raises ConfigError when arrays include non-string values" do
      create_test_directory do |test_dir|
        config_content = <<~YAML
          keywords:
            - TODO
            - 123
        YAML
        create_file(".jammer.yml", config_content)
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /non-empty strings/)
      end
    end

    it "raises ConfigError for unknown keys" do
      create_test_directory do |test_dir|
        create_file(".jammer.yml", "unknown_key: true")
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /Unknown setting/)
      end
    end

    it "raises ConfigError for invalid YAML syntax" do
      create_test_directory do |test_dir|
        create_file(".jammer.yml", "keywords: [TODO")
        expect { Jammer::Config.new(test_dir) }.to raise_error(Jammer::ConfigError, /Invalid syntax/)
      end
    end
  end
end
