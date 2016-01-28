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

  describe 'with an invalid command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir
    end

    it 'displays message' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new(['xxx'], env)

      expect { cmd.execute }.to output(/invalid command/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with an empty Commandfile but internal command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-commandfile')

      Dir.chdir @newdir
    end

    it 'allows running the command' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new(['version'], env)

      expect { cmd.execute }.to_not output(/no commands/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with missing command parameters' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/parameters')

      Dir.chdir @newdir
    end

    it 'displays an error' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new(['paramecho'], env)

      expect { cmd.execute }.to(
        output(/not enough parameters.+paramecho/i).to_stdout
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'with a proc/lambda as script' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/script-proc')

      Dir.chdir @newdir
    end

    it 'calls lambda before running' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new(['lambdaecho'], env)

      expect { cmd.execute }.to output(/parameters.+lambdaecho/i).to_stdout
    end

    it 'calls proc before running' do
      env = Vagrant::Environment.new(cwd: @newdir)
      cmd = described_class.new(['procecho'], env)

      expect { cmd.execute }.to output(/parameters.+procecho/i).to_stdout
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end
end
