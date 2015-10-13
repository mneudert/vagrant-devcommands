require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Definer do
  Definer = VagrantPlugins::DevCommands::Definer

  describe 'command definition' do
    it 'allows definition from hash' do
      Definer.define 'from_hash', box: :test, command: 'command from hash'

      cmd = Definer.commands['from_hash']

      expect(cmd[:box]).to eq(:test)
      expect(cmd[:command]).to eq('command from hash')
    end

    it 'allows definition from string' do
      Definer.define 'from_string', 'command from string'

      cmd = Definer.commands['from_string']

      expect(cmd[:command]).to eq('command from string')
    end
  end
end
