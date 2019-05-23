require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Model::Command do
  describe 'with configured parameters' do
    it 'interpolates values' do
      cmd = described_class.new(name: 'foo',
                                parameters: { that: {} },
                                script: 'echo "%<that>s"')

      expect(cmd.run_script(['--that', 'works'])).to eq('echo "works"')
      expect(cmd.run_script(['--that', 'works also'])).to(
        eq('echo "works also"')
      )
    end
  end

  describe 'with literal percent sign' do
    it 'needs special escaping' do
      cmd = described_class.new(name: 'foo', script: 'foo %%s %%bar')

      expect(cmd.run_script([])).to eq('foo %s %bar')
    end
  end

  describe 'with missing parameters' do
    it 'raises a KeyError' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: {} },
                                script: 'echo "%<what>s"')

      expect { cmd.run_script([]) }.to raise_error(KeyError)
    end

    it 'raises a KeyError (:passthru)' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: { passthru: true } },
                                script: 'echo "%<what>s"')

      expect { cmd.run_script([]) }.to raise_error(KeyError)
    end
  end

  describe 'with a proc/lambda as script' do
    it 'calls lambda' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: {} },
                                script: lambda {
                                  'echo "%<what>s"'
                                })

      expect(cmd.run_script(['--what', 'bar'])).to eq('echo "bar"')
    end

    it 'calls lambda with parsed argv' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: {} },
                                script: lambda { |params|
                                  'echo "%<what>s == ' + params[:what] + '"'
                                })

      expect(cmd.run_script(['--what', 'bar'])).to eq('echo "bar == bar"')
    end

    it 'calls proc' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: {} },
                                script: proc {
                                  'echo "%<what>s"'
                                })

      expect(cmd.run_script(['--what', 'bar'])).to eq('echo "bar"')
    end

    it 'calls proc with parsed argv' do
      cmd = described_class.new(name: 'foo',
                                parameters: { what: {} },
                                script: proc { |params|
                                  'echo "%<what>s == ' + params[:what] + '"'
                                })

      expect(cmd.run_script(['--what', 'bar'])).to eq('echo "bar == bar"')
    end
  end
end
