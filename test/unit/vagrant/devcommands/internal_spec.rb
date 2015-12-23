require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Internal do
  registry = VagrantPlugins::DevCommands::Registry

  describe 'displaying command list' do
    it 'includes internal commands' do
      reg          = registry.new
      reg.commands = { 'foo' => { command: 'foo' } }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to output(/version/).to_stdout
      expect { internal.run('help', []) }.to output(/help/).to_stdout
    end
  end

  describe 'internal help command' do
    it 'notifies if no command is available' do
      internal = described_class.new(registry.new)

      expect { internal.run('help', []) }.to output(/no commands/i).to_stdout
    end

    it 'displays a list of available commands' do
      reg          = registry.new
      reg.commands = {
        'bar' => { command: 'bar' },
        'foo' => { command: 'foo' }
      }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to output(/bar/).to_stdout
      expect { internal.run('help', []) }.to output(/foo/).to_stdout
    end

    it 'display description if available' do
      reg          = registry.new
      reg.commands = {
        'bar' => { command: 'bar' },
        'foo' => { command: 'foo', desc: 'has a description' }
      }

      internal = described_class.new(reg)

      expect { internal.run('help', []) }.to(
        output(/has a description/).to_stdout
      )
    end
  end

  describe 'internal version command' do
    it 'displays the plugin version' do
      version  = VagrantPlugins::DevCommands::VERSION
      internal = described_class.new(registry.new)

      expect { internal.run('version', []) }.to output(/#{version}/).to_stdout
    end
  end
end
