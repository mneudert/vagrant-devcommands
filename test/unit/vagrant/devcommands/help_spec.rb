require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Help do
  help     = VagrantPlugins::DevCommands::Help
  registry = VagrantPlugins::DevCommands::Registry

  describe 'help output' do
    it 'notifies if no command is known' do
      expect { help.display(registry.new) }.to output(/no commands/i).to_stdout
    end

    it 'displays a list of available commands' do
      reg          = registry.new
      reg.commands = {
        'bar' => { command: 'bar' },
        'foo' => { command: 'foo' }
      }

      expect { help.display(reg) }.to output(/bar/).to_stdout
      expect { help.display(reg) }.to output(/foo/).to_stdout
    end

    it 'display description if available' do
      reg          = registry.new
      reg.commands = {
        'bar' => { command: 'bar' },
        'foo' => { command: 'foo', desc: 'has a description' }
      }

      expect { help.display(reg) }.to output(/has a description/).to_stdout
    end
  end
end
