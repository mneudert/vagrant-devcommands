require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  chain_model   = VagrantPlugins::DevCommands::Model::Chain
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
      expect(messages).to match(/github/)
      expect(messages).to match(/README.md/)
    end
  end

  describe 'running help for an unknown command (or without command)' do
    it 'display chain list' do
      chain_commands = [{ command: 'bar' }]
      chain_foo      = chain_model.new(name: 'foo', commands: chain_commands)
      cmd_bar        = command_model.new(name: 'bar', script: 'bar')

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
  end
end
