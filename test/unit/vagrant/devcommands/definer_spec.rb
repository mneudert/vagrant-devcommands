require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Definer do
  definer = VagrantPlugins::DevCommands::Definer

  describe 'command definition' do
    it 'allows definition from hash' do
      definer.define 'from_hash', box: :test, command: 'command from hash'

      cmd = definer.commands['from_hash']

      expect(cmd[:box]).to eq(:test)
      expect(cmd[:script]).to eq('command from hash')
    end

    it 'allows definition from string' do
      definer.define 'from_string', 'command from string'

      cmd = definer.commands['from_string']

      expect(cmd[:script]).to eq('command from string')
    end
  end
end
