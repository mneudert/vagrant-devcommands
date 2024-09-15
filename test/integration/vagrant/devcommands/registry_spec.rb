# frozen_string_literal: true

require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::Registry do
  include_context 'commandfile_cwd'

  commandfile = VagrantPlugins::DevCommands::Commandfile

  describe 'chain definition' do
    before do
      cwd('integration/fixtures/chain-commandfile')

      @env = cwd_env
    end

    it 'allows defining chains' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.chains['xyz'].commands).to eq([{ command: 'bar' },
                                                     { command: 'foo' }])
    end

    it 'detects invalid chains' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.valid_chain?('xyz')).to be true
      expect(registry.valid_chain?('fump')).to be false
    end
  end

  describe 'command definition' do
    before do
      cwd('integration/fixtures/simple-commandfile')

      @env = cwd_env
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
  end

  describe 'command alias definition' do
    before do
      cwd('integration/fixtures/command-alias-commandfile')

      @env = cwd_env
    end

    it 'allows defining command aliases' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.command_aliases['bar'].command).to eq('foo')
    end

    it 'detects invalid commands' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)

      expect(registry.valid_command_alias?('foo')).to be false
      expect(registry.valid_command_alias?('bar')).to be true
    end
  end

  describe 'defining reserved commands' do
    it 'displays a message' do
      cwd('integration/fixtures/reserved-commands')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      described_class::RESERVED_COMMANDS.each do |command|
        expect(messages).to match(/#{command}.+reserved/i)
      end
    end
  end

  describe 'defining chain without commands' do
    it 'displays a message' do
      cwd('integration/fixtures/empty-chain')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/chain.+no commands/i)
    end
  end

  describe 'defining command alias without commands' do
    it 'displays a message' do
      cwd('integration/fixtures/empty-alias')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/alias.+no command/i)
    end
  end

  describe 'defining chain with unknown commands' do
    it 'displays a message' do
      cwd('integration/fixtures/missing-chain-commands')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/chain.+unknown command/i)
    end
  end

  describe 'defining command alias with unknown command' do
    it 'displays a message' do
      cwd('integration/fixtures/missing-alias-command')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/alias.+unknown command/i)
    end
  end

  describe 'defining command without script' do
    it 'displays a message' do
      cwd('integration/fixtures/missing-script')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      commands = %w[no_params no_script empty_script]
      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      commands.each do |command|
        expect(messages).to match(/#{command}.+no script/i)
        expect(registry.valid_command?(command)).to be(false)
      end
    end
  end

  describe 'defining command alias with name of an existing command' do
    before do
      cwd('integration/fixtures/naming-conflict-alias-command')

      @env = cwd_env
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/foo.+both.+ignored/im)
    end

    it 'removes conflicting command aliases from registry' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(registry.command_aliases.empty?).to be(true)
    end
  end

  describe 'defining chain with name of an existing command' do
    before do
      cwd('integration/fixtures/naming-conflict-chain-command')

      @env = cwd_env
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/foo.+both.+ignored/im)
    end

    it 'removes conflicting chains from registry' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(registry.chains.empty?).to be(true)
    end
  end

  describe 'defining command alias with name of a reserved command' do
    before do
      cwd('integration/fixtures/naming-conflict-alias-internal')

      @env = cwd_env
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/help.+internal.+ignored/im)
    end

    it 'removes conflicting command aliases from registry' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(registry.command_aliases.empty?).to be(true)
    end
  end

  describe 'defining chain with name of a reserved command' do
    before :context do
      cwd('integration/fixtures/naming-conflict-chain-internal')

      @env = cwd_env
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/help.+internal.+ignored/im)
    end

    it 'removes conflicting chains from registry' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(registry.chains.empty?).to be(true)
    end
  end

  describe 'defining command alias with name of an existing chain' do
    before do
      cwd('integration/fixtures/naming-conflict-alias-chain')

      @env = cwd_env
    end

    it 'displays a message' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/foo.+both.+ignored/im)
    end

    it 'removes conflicting command aliases from registry' do
      file     = commandfile.new(@env)
      registry = described_class.new(@env)

      registry.read_commandfile(file)
      expect(registry.command_aliases.empty?).to be(true)
    end
  end

  describe 'definitions with spaces in names' do
    it 'ignores names with spaces' do
      cwd('integration/fixtures/naming-spaces')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/command 'command spaces'.+ignored/im)
      expect(messages).to match(/chain 'chain spaces'.+ignored/im)
    end
  end

  describe 'reusing a name for an already existing entry' do
    it 'warns for chains' do
      cwd('integration/fixtures/duplicate-chain')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/chain.+'trigger_duplicate'.+more than once/i)
      expect(messages.scan('\'trigger_duplicate\'').count).to eq(1)
    end

    it 'warns for commands' do
      cwd('integration/fixtures/duplicate-command')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/command.+'trigger_duplicate'.+more than once/i)
      expect(messages.scan('\'trigger_duplicate\'').count).to eq(1)
    end

    it 'warns for command aliases' do
      cwd('integration/fixtures/duplicate-alias')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/alias.+'trigger_duplicate'.+more than once/i)
      expect(messages.scan('\'trigger_duplicate\'').count).to eq(1)
    end
  end

  describe 'using unknown options in a definition' do
    it 'warns for chains' do
      cwd('integration/fixtures/unknown-chain-options')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/chain.+'trigger_unknown'.+option/i)
    end

    it 'warns for commands' do
      cwd('integration/fixtures/unknown-command-options')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/command.+'trigger_unknown'.+option/i)
    end

    it 'warns for command aliases' do
      cwd('integration/fixtures/unknown-alias-options')

      env      = cwd_env
      file     = commandfile.new(env)
      registry = described_class.new(env)

      registry.read_commandfile(file)

      messages = env.ui.messages.map { |m| m[:message] }.join("\n")

      expect(messages).to match(/command alias.+'trigger_unknown'.+option/i)
    end
  end
end
