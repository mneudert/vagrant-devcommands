require_relative '../../spec_helper'

describe VagrantPlugins::DevCommands::CommandDef do
  describe 'with configured parameters' do
    it 'interpolates values' do
      cmd = described_class.new(name:       'foo',
                                parameters: { that: {} },
                                script:     'echo "%{that}"')

      expect(cmd.run_script(['--that', 'works'])).to eq('echo "works"')
      expect(cmd.run_script(['--that', 'works also'])).to(
        eq('echo "works also"')
      )
    end

    it 'allows optional parameters' do
      parameters = {
        mdtry: {},
        optnl: { optional: true }
      }

      cmd = described_class.new(name:       'foo',
                                parameters: parameters,
                                script:     'echo %{mdtry} %{optnl}')

      expect(cmd.run_script(['--mdtry', 'mandatory'])).to eq('echo mandatory')
      expect(
        cmd.run_script(['--mdtry', 'mandatory', '--optnl', 'optional'])
      ).to(
        eq('echo mandatory optional')
      )
    end

    it 'allows parameter defaults' do
      cmd = described_class.new(name:       'foo',
                                parameters: { dflt: { default: 'dflt' } },
                                script:     'echo "%{dflt}"')

      expect(cmd.run_script([])).to eq('echo "dflt"')
      expect(cmd.run_script(['--dflt', 'changed'])).to eq('echo "changed"')
    end

    it 'allows option value wrapping' do
      cmd = described_class.new(name:       'foo',
                                parameters: { wrppd: { wrap: '--opt %s' } },
                                script:     'script %{wrppd}')

      expect(cmd.run_script(['--wrppd', 'custom'])).to eq('script --opt custom')
    end
  end

  describe 'with literal percent sign' do
    it 'needs special escaping' do
      cmd = described_class.new(name: 'foo', script: 'foo %%s %%bar')

      expect(cmd.run_script([])).to eq('foo %s %bar')
    end
  end

  describe 'with missing parameters' do
    it 'displays raises a KeyError' do
      cmd = described_class.new(name:       'foo',
                                parameters: { what: {} },
                                script:     'echo "%{what}"')

      expect { cmd.run_script([]) }.to raise_error(KeyError)
    end
  end
end
