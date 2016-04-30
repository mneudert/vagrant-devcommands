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

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays help' do
      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_empty', File.dirname(__FILE__))
      )

      described_class.new([], @env).execute

      expect(@env.ui.messages[0][:message]).to match(/no commands/i)
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

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays help' do
      described_class.new([], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/usage.+vagrant run.+available.+bar.+foo/im)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with a global Commandfile' do
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

    it 'displays global commands' do
      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_notempty', File.dirname(__FILE__))
      )

      described_class.new([], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/global_command/im)
    end

    it 'prefers local over global commands' do
      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_notempty', File.dirname(__FILE__))
      )

      described_class.new([], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to_not match(/should not appear/im)
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

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'allows running the command' do
      described_class.new(['version'], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to_not match(/no commands/i)
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
      described_class
        .new(['paramecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to(
        match(/paramecho.+missing.+what/i)
      )
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
      described_class
        .new(['paramecho', '--will=raise'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to(
        match(/paramecho.+invalid.+--will/i)
      )
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
      @env.ui.messages = []

      described_class
        .new(['lambdaecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/lambdaecho.+parameter/i)
    end

    it 'calls proc before running' do
      @env.ui.messages = []

      described_class
        .new(['procecho'], @env)
        .execute

      expect(@env.ui.messages[0][:message]).to match(/procecho.+parameter/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
