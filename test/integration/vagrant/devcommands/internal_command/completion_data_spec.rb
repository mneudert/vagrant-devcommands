
require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::CompletionData do
  command = VagrantPlugins::DevCommands::Command

  describe 'fetching completion-data with an empty commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/empty-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'is empty' do
      command.new(%w[completion-data], @env).execute

      expect(@env.ui.messages).to eq([])
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'fetching completion-data' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/simple-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'is space-delimited' do
      command.new(%w[completion-data], @env).execute

      expect(@env.ui.messages[0][:message]).to eq(
        'bar completion-data dwayne foo help version'
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'fetching completion-data for a specific command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/help-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'returns flags and parameters space-delimited' do
      @env.ui.messages = []

      command.new(%w[completion-data unordered], @env).execute

      expect(@env.ui.messages[0][:message]).to eq('flg frst scnd')
    end

    it 'is empty for unknown commands' do
      @env.ui.messages = []

      command.new(%w[completion-data unknown], @env).execute

      expect(@env.ui.messages[0][:message]).to eq('')
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
