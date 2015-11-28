require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Internal do
  describe 'internal version command' do
    it 'displays the plugin version' do
      version  = VagrantPlugins::DevCommands::VERSION
      internal = described_class.new

      expect { internal.run('version') }.to output(/#{version}/).to_stdout
    end
  end
end
