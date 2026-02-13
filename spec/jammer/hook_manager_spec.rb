# frozen_string_literal: true

require "spec_helper"

describe Jammer::HookManager do
  describe ".init_config" do
    it "creates config and hook in a git repository" do
      create_test_git_repo do
        status = described_class.init_config

        expect(status).to eq({ config_created: true, hook_created: true })
        expect(File.exist?(".jammer.yml")).to be true
        expect(File.exist?(Jammer::PathResolver.hook_path)).to be true
      end
    end

    it "raises when a custom pre-commit hook exists" do
      create_test_git_repo do
        create_file(".jammer.yml", "keywords: [TODO]")
        create_file(".git/hooks/pre-commit", "#!/bin/sh\necho custom\n")

        expect { described_class.init_config }.to raise_error(Jammer::HookError, /custom pre-commit hook/)
      end
    end
  end

  describe ".uninstall_config" do
    it "removes config and hook created by jammer and returns status" do
      create_test_git_repo do
        described_class.init_config

        status = described_class.uninstall_config

        expect(status).to eq({ config_removed: true, hook_removed: true })
        expect(File.exist?(".jammer.yml")).to be false
        expect(File.exist?(Jammer::PathResolver.hook_path)).to be false
      end
    end

    it "removes only config outside a git repository and returns status" do
      create_test_directory do
        create_file(".jammer.yml", "keywords: [TODO]")

        status = described_class.uninstall_config

        expect(status).to eq({ config_removed: true, hook_removed: false })
        expect(File.exist?(".jammer.yml")).to be false
      end
    end

    it "does not remove a custom hook" do
      create_test_git_repo do
        create_file(".git/hooks/pre-commit", "#!/bin/sh\necho custom\n")

        expect { described_class.uninstall_config }.to raise_error(Jammer::HookError, /Custom pre-commit hook/)
        expect(File.exist?(".git/hooks/pre-commit")).to be true
      end
    end
  end
end
