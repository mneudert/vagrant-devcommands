require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Help do
  definer = VagrantPlugins::DevCommands::Definer
  help    = VagrantPlugins::DevCommands::Help

  describe 'help output' do
    it 'notifies if no command is known' do
      expect { help.display }.to output(/no commands/i).to_stdout
    end

    it 'displays a list of available commands' do
      definer.define 'bar', command: 'bar'
      definer.define 'foo', command: 'foo'

      expect { help.display }.to output(/bar/).to_stdout
      expect { help.display }.to output(/foo/).to_stdout
    end
  end
end
