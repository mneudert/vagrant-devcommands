require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  command     = VagrantPlugins::DevCommands::Command
  command_def = VagrantPlugins::DevCommands::CommandDef
  registry    = VagrantPlugins::DevCommands::Registry

  describe 'running help for an command command' do
    it 'displays command help message' do
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      described_class.new(env, reg).execute(['help'])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help for the help command/)
    end
  end

  describe 'running help for a command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/help-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays its help message if defined' do
      @env.ui.messages = []

      command.new(%w(help foo), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for foo/)
    end

    it 'displays an error if undefined' do
      @env.ui.messages = []

      command.new(%w(help bar), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    it 'displays its custom usage string if defined' do
      @env.ui.messages = []

      command.new(%w(help foo), @env).execute

      expect(@env.ui.messages[0][:message]).to match(/usage: vagrant run foo/i)
    end

    it 'displays a default usage string if non defined' do
      @env.ui.messages = []

      command.new(%w(help bar), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run \[box\] bar/i)
      )
    end

    it 'lists parameters if defined' do
      @env.ui.messages = []

      command.new(%w(help znk), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/znk --frst=<frst> \[--scnd=<scnd>\]/i)
      )
    end

    it 'lists mandatory params before optional params' do
      @env.ui.messages = []

      command.new(%w(help unordered), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/unordered --scnd=<scnd> \[--frst=<frst>\]/i)
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'running help for an unknown command' do
    it 'displays command list' do
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      described_class.new(env, reg).execute(['i-am-unknown'])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/available commands/i)
    end
  end
end
