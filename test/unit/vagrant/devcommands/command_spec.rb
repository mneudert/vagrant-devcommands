require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Command do
  describe 'without a Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/missing-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays warning' do
      described_class
        .new([], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/missing.+Commandfile/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with an empty Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'displays help' do
      cmd = described_class.new([], @env)

      expect { cmd.execute }.to output(/no commands/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with a Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'displays help' do
      cmd       = described_class.new([], @env)
      output_re = /usage.+vagrant run.+available.+bar.+foo/im

      expect { cmd.execute }.to output(output_re).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with an invalid command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays message' do
      allow($stdout).to receive(:puts)

      described_class
        .new(['xxx'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/invalid command/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with an empty Commandfile but internal command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'allows running the command' do
      cmd = described_class.new(['version'], @env)

      expect { cmd.execute }.to_not output(/no commands/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with missing command parameters' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/parameters')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays an error' do
      allow($stdout).to receive(:puts)

      described_class
        .new(['paramecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/paramecho.+missing/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with invalid command parameters' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/parameters')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays an error' do
      allow($stdout).to receive(:puts)

      described_class
        .new(['paramecho', '--will', 'raise'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/paramecho.+invalid/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with a proc/lambda as script' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/script-proc')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'calls lambda before running' do
      allow($stdout).to receive(:puts)

      @env.ui.messages = []

      described_class
        .new(['lambdaecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/lambdaecho.+parameters/i)
    end

    it 'calls proc before running' do
      allow($stdout).to receive(:puts)

      @env.ui.messages = []

      described_class
        .new(['procecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/procecho.+parameters/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
