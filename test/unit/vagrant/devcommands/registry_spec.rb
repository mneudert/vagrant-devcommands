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

    it 'detects invalid commands' do
      env      = Vagrant::Environment.new(cwd: @newdir)
      file     = commandfile.new(env)
      registry = described_class.new

      registry.read_commandfile(file)

      expect(registry.valid_command? 'foo').to be true
      expect(registry.valid_command? 'xxx').to be false
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'defining reserved commands' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/reserved-commands')

      Dir.chdir @newdir
    end

    it 'displays a message' do
      env      = Vagrant::Environment.new(cwd: @newdir)
      file     = commandfile.new(env)
      registry = described_class.new

      described_class::RESERVED_COMMANDS.each do |command|
        expect { registry.read_commandfile(file) }.to(
          output(/#{command}.+reserved/i).to_stdout
        )
      end
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
