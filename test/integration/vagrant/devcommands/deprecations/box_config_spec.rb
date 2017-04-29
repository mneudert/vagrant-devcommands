require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Command do
  describe 'using the deprecated configuration ":box"' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/deprecated-box-config')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays warning' do
      described_class
        .new([], @env)
        .execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/deprecated.+box.+machine.+update/im)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
