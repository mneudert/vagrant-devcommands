require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Registry do
  commandfile = VagrantPlugins::DevCommands::Commandfile

  describe 'legacy definition' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/legacy-commandfile')

      Dir.chdir @newdir
    end

    it 'prefers new over old' do
      env      = Vagrant::Environment.new(cwd: @newdir)
      file     = commandfile.new(env)
      registry = described_class.new

      registry.instance_eval do
        # stub to silence calls to `puts` (deprecation notice)
        def puts(*_args)
          ''
        end
      end

      registry.read_commandfile(file)

      expect(registry.commands['foo'][:script]).to eq('foo')
      expect(registry.commands['bar'][:script]).to eq('bar')
    end

    it 'displays a deprecation warning on use' do
      env      = Vagrant::Environment.new(cwd: @newdir)
      file     = commandfile.new(env)
      registry = described_class.new

      expect { registry.read_commandfile(file) }.to(
        output(/deprecated/).to_stdout
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
