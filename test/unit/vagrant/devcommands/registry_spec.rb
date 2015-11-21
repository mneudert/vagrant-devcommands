require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Registry do
  commandfile = VagrantPlugins::DevCommands::Commandfile

  describe 'command definition' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir
    end

    it 'allows defining commands' do
      env      = Vagrant::Environment.new(cwd: @newdir)
      file     = commandfile.new(env)
      registry = described_class.new

      registry.read_commandfile(file)

      expect(registry.commands['foo'][:script]).to eq('foo')
      expect(registry.commands['bar'][:script]).to eq('bar')
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
