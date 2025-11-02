# frozen_string_literal: true

require "spec_helper"

describe Jammer::ConfigManager do
  context "config file setup" do
    it "creates config file when it does not exist" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          result = Jammer::ConfigManager.setup

          expect(result).to be true
          expect(File.exist?(".jammer.yml")).to be true
        end
      end
    end

    it "returns false when config already exists and no force" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          # Create initial config
          File.write(".jammer.yml", "keywords: [TEST]")

          result = Jammer::ConfigManager.setup

          expect(result).to be false
        end
      end
    end

    it "overwrites config when force flag is set" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          # Create initial config
          File.write(".jammer.yml", "old content")

          result = Jammer::ConfigManager.setup(force: true)

          expect(result).to be true
          content = File.read(".jammer.yml")
          expect(content).not_to eq("old content")
        end
      end
    end

    it "copies example config content" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          Jammer::ConfigManager.setup

          content = File.read(".jammer.yml")
          expect(content).to include("keywords")
          expect(content).to include("exclude")
          expect(content).to include("commands")
        end
      end
    end
  end

  context "config file removal" do
    it "removes config file" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          File.write(".jammer.yml", "test content")
          expect(File.exist?(".jammer.yml")).to be true

          Jammer::ConfigManager.remove

          expect(File.exist?(".jammer.yml")).to be false
        end
      end
    end

    it "raises error when config does not exist" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          expect { Jammer::ConfigManager.remove }.to raise_error(Jammer::HookError)
        end
      end
    end
  end

  context "config file existence check" do
    it "returns true when config exists" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          File.write(".jammer.yml", "test")
          expect(Jammer::ConfigManager.exists?).to be true
        end
      end
    end

    it "returns false when config does not exist" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          expect(Jammer::ConfigManager.exists?).to be false
        end
      end
    end
  end

  context "error handling" do
    it "handles removal error gracefully" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          File.write(".jammer.yml", "test")

          # Mock File.delete to raise an error
          allow(File).to receive(:delete).and_raise(StandardError, "Permission denied")

          expect { Jammer::ConfigManager.remove }.to raise_error(Jammer::HookError, /removing config file/)
        end
      end
    end
  end

  context "integration" do
    it "setup and exists work together" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          expect(Jammer::ConfigManager.exists?).to be false
          Jammer::ConfigManager.setup
          expect(Jammer::ConfigManager.exists?).to be true
        end
      end
    end

    it "setup and remove work together" do
      create_test_directory do |test_dir|
        Dir.chdir(test_dir) do
          Jammer::ConfigManager.setup
          expect(Jammer::ConfigManager.exists?).to be true

          Jammer::ConfigManager.remove
          expect(Jammer::ConfigManager.exists?).to be false
        end
      end
    end
  end
end
