require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  chain_model   = VagrantPlugins::DevCommands::Model::Chain
  command       = VagrantPlugins::DevCommands::Command
  command_model = VagrantPlugins::DevCommands::Model::Command
  registry      = VagrantPlugins::DevCommands::Registry

  describe 'running help for an internal command' do
    it 'displays command help message' do
      cmd_foo      = command_model.new(name: 'foo', script: 'foo')
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

    it 'lists parameters with optional descriptions' do
      @env.ui.messages = []

      command.new(%w(help described), @env).execute

      expect(@env.ui.messages[3][:message]).to(
        match(/dscrbd\s+mandatory with description/i)
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'running help for an unknown command (or without command)' do
    it 'display chain list' do
      chain_foo    = chain_model.new(name: 'foo', commands: ['bar'])
      cmd_bar      = command_model.new(name: 'bar', script: 'bar')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.chains   = { 'foo' => chain_foo }
      reg.commands = { 'bar' => cmd_bar }

      described_class.new(env, reg).execute(['i-am-unknown'])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/command chains/i)
    end

    it 'displays command list' do
      cmd_foo      = command_model.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      described_class.new(env, reg).execute(['i-am-unknown'])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/available commands/i)
    end

    it 'displays extended help message' do
      cmd_foo      = command_model.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      described_class.new(env, reg).execute([])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/github/)
      expect(messages).to match(/README.md/)
    end
  end
end
