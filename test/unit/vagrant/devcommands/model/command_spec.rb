require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Model::Command do
  describe 'with configured parameters' do
    it 'interpolates values' do
      cmd = described_class.new(name:       'foo',
                                parameters: { that: {} },
                                script:     'echo "%<that>s"')

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
                                script:     'echo %<mdtry>s %<optnl>s')

      expect(cmd.run_script(['--mdtry', 'mandatory'])).to eq('echo mandatory')
      expect(
        cmd.run_script(['--mdtry', 'mandatory', '--optnl', 'optional'])
      ).to(
        eq('echo mandatory optional')
      )
    end

    it 'allows flags' do
      flags = {
        dflt: {}
      }

      cmd = described_class.new(name:   'foo',
                                flags:  flags,
                                script: 'echo "%<dflt>s"')

      expect(cmd.run_script([])).to eq('echo ""')
      expect(cmd.run_script(['--dflt'])).to eq('echo "--dflt"')
    end

    it 'allows flags with values' do
      flags = {
        dflt: { value: '--custom' }
      }

      cmd = described_class.new(name:   'foo',
                                flags:  flags,
                                script: 'echo "%<dflt>s"')

      expect(cmd.run_script(['--dflt'])).to eq('echo "--custom"')
    end

    it 'allows escaping parameter values' do
      param = { escape: { 'z' => 'y', 'y' => 'x' } }
      cmd   = described_class.new(name:       'foo',
                                  parameters: { escaped: param },
                                  script:     'script %<escaped>s')

      expect(cmd.run_script(['--escaped', 'foo_z_bar'])).to(
        eq('script foo_xyz_bar')
      )
    end

    it 'allows parameter defaults' do
      cmd = described_class.new(name:       'foo',
                                parameters: { dflt: { default: 'dflt' } },
                                script:     'echo "%<dflt>s"')

      expect(cmd.run_script([])).to eq('echo "dflt"')
      expect(cmd.run_script(['--dflt', 'changed'])).to eq('echo "changed"')
    end

    it 'allows parameter value wrapping' do
      cmd = described_class.new(name:       'foo',
                                parameters: { wrppd: { wrap: '--opt %s' } },
                                script:     'script %<wrppd>s')

      expect(cmd.run_script(['--wrppd', 'custom'])).to eq('script --opt custom')
    end

    it 'does not wrap unpassed optional parameters' do
      cmd = described_class.new(name:       'foo',
                                parameters: { wrppd: { optional: true,
                                                       wrap:     '--opt %s' } },
                                script:     'script %<wrppd>s')

      expect(cmd.run_script([])).to eq('script')
    end

    it 'does wrap unpassed optional parameters with empty default' do
      cmd = described_class.new(name:       'foo',
                                parameters: { wrppd: { wrap:    '--opt %s',
                                                       default: '' } },
                                script:     'script %<wrppd>s')

      expect(cmd.run_script([])).to eq('script --opt')
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
      cmd = described_class.new(name:       'foo',
                                parameters: { what: {} },
                                script:     'echo "%<what>s"')

      expect { cmd.run_script([]) }.to raise_error(KeyError)
    end
  end
end
