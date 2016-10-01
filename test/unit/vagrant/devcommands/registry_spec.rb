require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::Registry do
  commandfile = VagrantPlugins::DevCommands::CommandFile

  describe 'chain definition' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/chain-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'allows defining chains' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.chains['xyz'].commands).to eq(%w(bar foo))
    end

    it 'detects invalid chains' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.valid_chain?('xyz')).to be true
      expect(registry.valid_chain?('fump')).to be false
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'command definition' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/simple-commandfile')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(cwd: @newdir)
    end

    it 'allows defining commands' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.commands['foo'].script).to eq('foo')
      expect(registry.commands['bar'].script).to eq('bar')
    end

    it 'auto registers the commands name' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.commands['foo'].name).to eq('foo')
      expect(registry.commands['bar'].name).to eq('bar')
    end

    it 'detects invalid commands' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.valid_command?('foo')).to be true
      expect(registry.valid_command?('xxx')).to be false
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

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      described_class::RESERVED_COMMANDS.each do |command|
        expect(messages).to match(/#{command}.+reserved/i)
      end
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'defining chain without commands' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/empty-chain')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(@env.ui.messages.map { |m| m[:message] }.join("\n")).to(
        match(/chain.+no commands/i)
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'defining command without script' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/missing-script')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      commands = %w(no_params no_script empty_script)
      messages = @env.ui.messages.map { |m| m[:message] }.join("\n")

      commands.each do |command|
        expect(messages).to match(/#{command}.+no script/i)
        expect(registry.valid_command?(command)).to be(false)
      end
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'defining chaing with name of existing command' do
    before :context do
      @olddir = Dir.pwd
      @newdir = File.join(File.dirname(__FILE__),
                          '../../fixtures/naming-conflicts')

      Dir.chdir @newdir

      @env = Vagrant::Environment.new(
        cwd:      @newdir,
        ui_class: Helpers::UI::Tangible
      )
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(@env.ui.messages.map { |m| m[:message] }.join("\n")).to(
        match(/foo.+both.+ignored/im)
      )
    end

    after :context do
      Dir.chdir(@olddir)
    end
  end

  describe 'validating a reserved command' do
    it 'always returns true' do
      registry = described_class.new(nil)

      described_class::RESERVED_COMMANDS.each do |name|
        expect(registry.valid_command?(name)).to be true
      end
    end
  end
end
