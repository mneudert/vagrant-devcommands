require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Command do
  include_context 'commandfile_cwd'

  describe 'using the deprecated configuration ":box"' do
    it 'displays warning' do
      cwd(File.join(File.dirname(__FILE__),
                    '../../../fixtures/deprecated-box-config'))

      env = cwd_env

      described_class.new([], env).execute
      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/deprecated.+box.+machine.+update/im)
    end
  end
end
