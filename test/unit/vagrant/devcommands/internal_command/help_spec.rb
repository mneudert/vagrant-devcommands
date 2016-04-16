require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::InternalCommand::Help do
  command     = VagrantPlugins::DevCommands::Command
  command_def = VagrantPlugins::DevCommands::CommandDef
  registry    = VagrantPlugins::DevCommands::Registry

  describe 'running help for an command command' do
    it 'displays command help message' do
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      reg          = registry.new
      reg.commands = { 'foo' => cmd_foo }

      help = described_class.new(reg)

      expect { help.execute(['help']) }.to(
        output(/help for the help command/).to_stdout
      )
    end
  end

  describe 'running help for a command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../../fixtures/help-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'displays its help message if defined' do
      cmd = command.new(%w(help foo), @env)

      expect { cmd.execute }.to(
        output(/help message for foo/).to_stdout
      )
    end

    it 'displays an error if undefined' do
      cmd = command.new(%w(help bar), @env)

      expect { cmd.execute }.to(
        output(/no detailed help/i).to_stdout
      )
    end

    it 'displays its custom usage string if defined' do
      cmd = command.new(%w(help foo), @env)

      expect { cmd.execute }.to(
        output(/usage: vagrant run foo/i).to_stdout
      )
    end

    it 'displays a default usage string if non defined' do
      cmd = command.new(%w(help bar), @env)

      expect { cmd.execute }.to(
        output(/usage: vagrant run \[box\] bar/i).to_stdout
      )
    end

    it 'lists parameters if defined' do
      cmd = command.new(%w(help znk), @env)

      expect { cmd.execute }.to(
        output(/znk --frst=<frst> \[--scnd=<scnd>\]/i).to_stdout
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'running help for an unknown command' do
    it 'displays command list' do
      cmd_foo      = command_def.new(name: 'foo', script: 'foo')
      reg          = registry.new
      reg.commands = { 'foo' => cmd_foo }

      help = described_class.new(reg)

      expect { help.execute(['i-am-unknown']) }.to(
        output(/available commands/i).to_stdout
      )
    end
  end
end
