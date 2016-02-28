require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::CommandDef do
  describe 'with missing parameters' do
    it 'displays raises an ArgumentError' do
      cmd = described_class.new(name: 'foo', script: 'echo "%s"')

      expect { cmd.run_script([]) }.to raise_error(ArgumentError)
    end
  end
end
