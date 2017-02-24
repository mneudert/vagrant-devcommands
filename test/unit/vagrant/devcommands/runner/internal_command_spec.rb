require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Runner::InternalCommand do
  command_model = VagrantPlugins::DevCommands::Model::Command
  registry      = VagrantPlugins::DevCommands::Registry

  describe 'displaying command list' do
    it 'includes internal commands' do
      cmd_foo      = command_model.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      described_class.new(nil, [], env, reg).run('help', [])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/version/)
      expect(messages).to match(/help/)
    end
  end

  describe 'internal help command' do
    it 'notifies if no command is available' do
      env = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg = registry.new(nil)

      described_class.new(nil, [], env, reg).run('help', [])

      expect(env.ui.messages[0][:message]).to match(/no commands/i)
    end

    it 'displays a list of available commands' do
      cmd_bar      = command_model.new(name: 'bar', script: 'bar')
      cmd_foo      = command_model.new(name: 'foo', script: 'foo')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'bar' => cmd_bar, 'foo' => cmd_foo }

      described_class.new(nil, [], env, reg).run('help', [])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/bar/)
      expect(messages).to match(/foo/)
    end

    it 'display description if available' do
      cmd_bar      = command_model.new(name: 'bar', script: 'bar')
      cmd_foo      = command_model.new(name: 'foo', script: 'foo',
                                       desc: 'has a description')
      env          = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg          = registry.new(nil)
      reg.commands = { 'bar' => cmd_bar, 'foo' => cmd_foo }

      described_class.new(nil, [], env, reg).run('help', [])

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/has a description/)
    end
  end

  describe 'internal version command' do
    it 'displays the plugin version' do
      env      = Vagrant::Environment.new(ui_class: Helpers::UI::Tangible)
      reg      = registry.new(nil)
      internal = described_class.new(nil, [], env, reg)
      version  = VagrantPlugins::DevCommands::VERSION

      internal.run('version', [])

      expect(env.ui.messages[0][:message]).to match(/#{version}/)
    end
  end
end
