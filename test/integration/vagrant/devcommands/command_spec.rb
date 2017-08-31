require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::Command do
  include_context 'commandfile_cwd'

  describe 'without a Commandfile' do
    it 'displays warning and usage information' do
      cwd('integration/fixtures/missing-commandfile')

      env = cwd_env

      described_class.new([], env).execute
      expect(env.ui.messages[0][:message]).to match(/missing.+Commandfile/i)
      expect(env.ui.messages[2][:message]).to match(/README\.md/i)
    end
  end

  describe 'with an empty Commandfile' do
    it 'displays help' do
      cwd('integration/fixtures/empty-commandfile')

      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_empty', File.dirname(__FILE__))
      )

      env = cwd_env

      described_class.new([], env).execute
      expect(env.ui.messages[0][:message]).to match(/no commands/i)
    end
  end

  describe 'with a Commandfile' do
    it 'displays help' do
      cwd('integration/fixtures/simple-commandfile')

      env = cwd_env

      described_class.new([], env).execute
      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/usage.+vagrant run.+available.+bar.+foo/im)
    end
  end

  describe 'with a global Commandfile' do
    before :each do
      cwd('integration/fixtures/simple-commandfile')

      @env = cwd_env
    end

    it 'displays global commands' do
      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_notempty', File.dirname(__FILE__))
      )

      described_class.new([], @env).execute
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to match(/global_command/im)
    end

    it 'prefers local over global commands' do
      allow(Dir).to receive(:home).and_return(
        File.expand_path('../../fixtures/home_notempty', File.dirname(__FILE__))
      )

      described_class.new([], @env).execute
      expect(
        @env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to_not match(/should not appear/im)
    end
  end

  describe 'with an invalid command' do
    before :each do
      cwd('integration/fixtures/simple-commandfile')

      @env = cwd_env
    end

    it 'displays message' do
      described_class.new(['xxx'], @env).execute
      expect(@env.ui.messages[0][:message]).to match(/invalid command/i)
    end

    it 'suggests an alternative' do
      described_class.new(['duane'], @env).execute
      expect(@env.ui.messages[3][:message]).to match(/dwayne/i)
    end
  end

  describe 'with an empty Commandfile but internal command' do
    it 'allows running the command' do
      cwd('integration/fixtures/empty-commandfile')

      env = cwd_env

      described_class.new(['version'], env).execute
      expect(
        env.ui.messages.map { |m| m[:message] }.join("\n")
      ).to_not match(/no commands/i)
    end
  end

  describe 'with missing command parameters' do
    before :each do
      cwd('integration/fixtures/parameters')

      @env = cwd_env
    end

    it 'displays an error' do
      described_class.new(['paramecho'], @env).execute
      expect(
        @env.ui.messages[0][:message]
      ).to match(/paramecho.+missing.+what/i)
    end

    it 'displays command usage help' do
      described_class.new(['paramecho'], @env).execute
      expect(
        @env.ui.messages[2][:message]
      ).to match(/vagrant run.+paramecho/i)
    end
  end

  describe 'with invalid command parameters' do
    before :each do
      cwd('integration/fixtures/parameters')

      @env = cwd_env
    end

    it 'displays an error' do
      described_class.new(['paramecho', '--will=raise'], @env).execute
      expect(
        @env.ui.messages[0][:message]
      ).to match(/paramecho.+invalid.+--will/i)
    end

    it 'displays command usage help' do
      described_class.new(['paramecho', '--will=raise'], @env).execute
      expect(
        @env.ui.messages[2][:message]
      ).to match(/vagrant run.+paramecho/i)
    end
  end

  describe 'with command parameters values not allowed' do
    before :each do
      cwd('integration/fixtures/parameters')

      @env = cwd_env
    end

    it 'displays an error' do
      described_class.new(['limitecho', '--what=raise'], @env).execute
      expect(
        @env.ui.messages[0][:message]
      ).to match(/limitecho.+not allowed.+--what/i)
    end

    it 'displays command usage help' do
      described_class.new(['limitecho', '--what=raise'], @env).execute
      expect(
        @env.ui.messages[2][:message]
      ).to match(/vagrant run.+limitecho/i)
    end
  end

  describe 'with a proc/lambda as script' do
    before :each do
      cwd('integration/fixtures/script-proc')

      @env = cwd_env
    end

    it 'calls lambda before running' do
      described_class.new(['lambdaecho'], @env).execute
      expect(@env.ui.messages[0][:message]).to match(/lambdaecho.+parameter/i)
    end

    it 'calls proc before running' do
      described_class.new(['procecho'], @env).execute
      expect(@env.ui.messages[0][:message]).to match(/procecho.+parameter/i)
    end
  end
end
