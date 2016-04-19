require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Internal do
  command_def = VagrantPlugins::DevCommands::CommandDef
  registry    = VagrantPlugins::DevCommands::Registry

  describe 'displaying command list' do
    it 'includes internal commands' do
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      reg          = registry.new(nil)
      reg.commands = { 'foo' => cmd_foo }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to output(/version/).to_stdout
      expect { internal.run('help', []) }.to output(/help/).to_stdout
    end
  end

  describe 'internal help command' do
    it 'notifies if no command is available' do
      reg      = registry.new(nil)
      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to output(/no commands/i).to_stdout
    end

    it 'displays a list of available commands' do
      cmd_bar      = command_def.new(name: 'bar', script: 'bar')
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      reg          = registry.new(nil)
      reg.commands = { 'bar' => cmd_bar, 'foo' => cmd_foo }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to output(/bar/).to_stdout
      expect { internal.run('help', []) }.to output(/foo/).to_stdout
    end

    it 'display description if available' do
      cmd_bar      = command_def.new(name: 'bar', script: 'bar')
      cmd_foo      = command_def.new(name: 'foo', script: 'foo',
                                     desc: 'has a description')
      reg          = registry.new(nil)
      reg.commands = { 'bar' => cmd_bar, 'foo' => cmd_foo }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to(
        output(/has a description/).to_stdout
      )
    end
  end

  describe 'internal version command' do
    it 'displays the plugin version' do
      reg      = registry.new(nil)
      internal = described_class.new(reg)
      version  = VagrantPlugins::DevCommands::VERSION

      expect { internal.run('version', []) }.to output(/#{version}/).to_stdout
    end
  end
end
