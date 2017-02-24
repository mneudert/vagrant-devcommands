require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  command = VagrantPlugins::DevCommands::Command

  describe 'running help for a command' do
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

    it 'displays its help message if defined' do
      @env.ui.messages = []

      command.new(%w(help foo), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for foo/)
    end

    it 'displays an error if undefined' do
      @env.ui.messages = []

      command.new(%w(help bar), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    it 'displays its custom usage string if defined' do
      @env.ui.messages = []

      command.new(%w(help foo), @env).execute

      expect(@env.ui.messages[0][:message]).to match(/usage: vagrant run foo/i)
    end

    it 'displays a default usage string if non defined' do
      @env.ui.messages = []

      command.new(%w(help bar), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/usage: vagrant run \[box\] bar/i)
      )
    end

    it 'lists flags if defined' do
      @env.ui.messages = []

      command.new(%w(help fmp), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/fmp \[--flagged\]/i)
      )
    end

    it 'lists parameters if defined' do
      @env.ui.messages = []

      command.new(%w(help znk), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/znk --frst=<frst> \[--scnd=<scnd>\]/i)
      )
    end

    it 'uses correct order for param/flag listing' do
      @env.ui.messages = []

      command.new(%w(help unordered), @env).execute

      expect(@env.ui.messages[0][:message]).to(
        match(/unordered --scnd=<scnd> \[--frst=<frst>\] \[--flg\]/i)
      )
    end

    it 'lists flags with optional descriptions' do
      @env.ui.messages = []

      command.new(%w(help described), @env).execute

      expect(@env.ui.messages[6][:message]).to(
        match(/f_dscrbd\s+flag with description/i)
      )
    end

    it 'lists parameters with optional descriptions' do
      @env.ui.messages = []

      command.new(%w(help described), @env).execute

      expect(@env.ui.messages[3][:message]).to(
        match(/p_dscrbd\s+mandatory with description/i)
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'running help for a chain' do
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

    it 'lists commands for chains (in order)' do
      @env.ui.messages = []

      command.new(%w(help chained), @env).execute

      expect(@env.ui.messages[3][:message]).to match(/foo/i)
      expect(@env.ui.messages[4][:message]).to match(/bar/i)
    end

    it 'displays its help message if defined' do
      @env.ui.messages = []

      command.new(%w(help chainhelp), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/help message for chainhelp/)
    end

    it 'displays an error if undefined' do
      @env.ui.messages = []

      command.new(%w(help chained), @env).execute

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/no detailed help/i)
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
