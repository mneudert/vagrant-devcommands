require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Internal do
  command  = VagrantPlugins::DevCommands::Command
  registry = VagrantPlugins::DevCommands::Registry

  describe 'calling an internal command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-commandfile')

      Dir.chdir @newdir
    end

    it 'displays its name' do
      env = Vagrant::Environment.new(cwd: @newdir)

      registry::RESERVED_COMMANDS.each do |name|
        cmd = command.new([name], env)

        expect { cmd.execute }.to output(/internal.+#{name}/i).to_stdout
      end
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
