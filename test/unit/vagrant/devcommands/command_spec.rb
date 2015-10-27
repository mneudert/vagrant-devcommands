require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Command do
  describe 'without a Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/missing-commandfile')

      Dir.chdir @newdir
    end

    it 'displays warning' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new([], env)

      expect { cmd.execute }.to output(/missing.+Commandfile/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with an empty Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-commandfile')

      Dir.chdir @newdir
    end

    it 'displays help' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new([], env)

      expect { cmd.execute }.to output(/no commands/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with a Commandfile' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir
    end

    it 'displays help' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new([], env)

      output_re = /usage.+vagrant run.+available.+bar.+foo/im

      expect { cmd.execute }.to output(output_re).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
