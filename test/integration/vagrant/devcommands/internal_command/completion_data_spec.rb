require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::CompletionData do
  include_context 'commandfile_cwd'

  command = VagrantPlugins::DevCommands::Command

  describe 'fetching completion-data with an empty commandfile' do
    it 'is empty' do
      cwd(File.join(File.dirname(__FILE__),
                    '../../../fixtures/empty-commandfile'))

      env = cwd_env

      command.new(%w[completion-data], env).execute
      expect(env.ui.messages).to eq([])
    end
  end

  describe 'fetching completion-data' do
    it 'is space-delimited' do
      cwd(File.join(File.dirname(__FILE__),
                    '../../../fixtures/simple-commandfile'))

      env = cwd_env

      command.new(%w[completion-data], env).execute
      expect(env.ui.messages[0][:message]).to eq(
        'bar completion-data dwayne foo help version'
      )
    end
  end

  describe 'fetching completion-data for a specific command' do
    before :each do
      cwd(File.join(File.dirname(__FILE__),
                    '../../../fixtures/help-commandfile'))

      @env = cwd_env
    end

    it 'returns flags and parameters space-delimited' do
      command.new(%w[completion-data unordered], @env).execute
      expect(@env.ui.messages[0][:message]).to eq('flg frst scnd')
    end

    it 'is empty for unknown commands' do
      command.new(%w[completion-data unknown], @env).execute
      expect(@env.ui.messages[0][:message]).to eq('')
    end
  end
end
