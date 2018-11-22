require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  include_context 'commandfile_cwd'

  command = VagrantPlugins::DevCommands::Command

  describe 'running help for a command' do
    before :each do
      cwd('integration/fixtures/help-commandfile')

      @env = cwd_env
    end

    it 'displays its help message if defined' do
      command.new(%w[help foo], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for foo/)
    end

    it 'displays an error if undefined' do
      command.new(%w[help bar], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    it 'displays its custom usage string if defined' do
      command.new(%w[help foo], @env).execute

      expect(@env.ui.messages[0][:message]).to match(/usage: vagrant run foo/i)
    end

    it 'displays a default usage string if non defined' do
      command.new(%w[help bar], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run \[machine\] bar/i)
      )
    end

    it 'lists flags if defined' do
      command.new(%w[help fmp], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/fmp \[--flagged\]/i)
      )
    end

    it 'lists parameters if defined' do
      command.new(%w[help znk], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/znk --frst=<frst> \[--scnd=<scnd>\]/i)
      )
    end

    it 'lists parameters with defaults as optional' do
      command.new(%w[help default_is_optional], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/default_is_optional \[--frst=<frst>\]/i)
      )
    end

    it 'uses correct order for param/flag listing' do
      command.new(%w[help unordered], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/unordered --scnd=<scnd> \[--frst=<frst>\] \[--flg\]/i)
      )
    end

    it 'lists flags with optional descriptions' do
      command.new(%w[help described], @env).execute

      expect(@env.ui.messages[6][:message]).to(
        match(/f_dscrbd\s+flag with description/i)
      )
    end

    it 'lists parameters with optional descriptions' do
      command.new(%w[help described], @env).execute

      expect(@env.ui.messages[3][:message]).to(
        match(/p_dscrbd\s+mandatory with description/i)
      )
    end
  end

  describe 'running help for a chain' do
    before :each do
      cwd('integration/fixtures/help-commandfile')

      @env = cwd_env
    end

    it 'lists commands for chains (in order)' do
      command.new(%w[help chained], @env).execute

      expect(@env.ui.messages[3][:message]).to match(/foo/i)
      expect(@env.ui.messages[4][:message]).to match(/bar/i)
    end

    it 'displays its help message if defined' do
      command.new(%w[help chainhelp], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for chainhelp/)
    end

    it 'displays an error if undefined' do
      command.new(%w[help chained], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    it 'displays its custom usage string if defined' do
      command.new(%w[help chainhelp], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run chainhelp/i)
      )
    end

    it 'displays a default usage string if non defined' do
      command.new(%w[help chained], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run \[machine\] chained/i)
      )
    end
  end

  describe 'running help for a command alias' do
    before :each do
      cwd('integration/fixtures/help-commandfile')

      @env = cwd_env
    end

    it 'displays its help message if defined' do
      command.new(%w[help aliashelp], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for aliashelp/)
    end

    it 'displays an error if undefined' do
      command.new(%w[help aliased], @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    it 'displays its custom usage string if defined' do
      command.new(%w[help aliashelp], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run aliashelp/i)
      )
    end

    it 'displays a default usage string if non defined' do
      command.new(%w[help aliased], @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run \[machine\] aliased/i)
      )
    end

    it 'displays the aliased vagrant run command' do
      command.new(%w[help aliased], @env).execute

      expect(@env.ui.messages[2][:message]).to(
        match(/alias for: vagrant run \[machine\] bar --some="param"/i)
      )
    end
  end
end
