require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::ParamParser do
  COMMAND = VagrantPlugins::DevCommands::Model::Command

  let(:parser) { described_class.new }

  describe 'with configured parameters' do
    it 'allows optional parameters' do
      command = COMMAND.new(
        parameters: {
          mdtry: {},
          optnl: { optional: true }
        }
      )

      expect(
        parser.parse!(command, ['--mdtry', 'mandatory'])
      ).to eq(mdtry: 'mandatory', optnl: '')

      expect(
        parser.parse!(
          command,
          ['--mdtry', 'mandatory', '--optnl', 'optional']
        )
      ).to eq(mdtry: 'mandatory', optnl: 'optional')
    end

    it 'allows flags' do
      command = COMMAND.new(flags: { dflt: {} })

      expect(parser.parse!(command, [])).to eq(dflt: '')
      expect(parser.parse!(command, ['--dflt'])).to eq(dflt: '--dflt')
    end

    it 'allows flags with values' do
      command = COMMAND.new(flags: { dflt: { value: '--custom' } })

      expect(parser.parse!(command, ['--dflt'])).to eq(dflt: '--custom')
    end

    it 'allows escaping parameter values' do
      command = COMMAND.new(
        parameters: {
          escaped: {
            escape: { 'z' => 'y', 'y' => 'x' }
          }
        }
      )

      expect(
        parser.parse!(command, ['--escaped', 'foo_z_bar'])
      ).to eq(escaped: 'foo_xyz_bar')
    end

    it 'allows parameter defaults' do
      command = COMMAND.new(parameters: { dflt: { default: 'dflt' } })

      expect(parser.parse!(command, [])).to eq(dflt: 'dflt')
      expect(
        parser.parse!(command, ['--dflt', 'changed'])
      ).to eq(dflt: 'changed')
    end

    it 'allows parameter value wrapping' do
      command = COMMAND.new(parameters: { wrppd: { wrap: '--opt %s' } })

      expect(
        parser.parse!(command, ['--wrppd', 'custom'])
      ).to eq(wrppd: '--opt custom')
    end

    it 'does not wrap unpassed optional parameters' do
      command = COMMAND.new(
        parameters: {
          wrppd: {
            optional: true,
            wrap:     '--opt %s'
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(wrppd: '')
    end

    it 'does wrap unpassed optional parameters with empty default' do
      command = COMMAND.new(
        parameters: {
          wrppd: {
            wrap:    '--opt %s',
            default: ''
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(wrppd: '--opt ')
    end

    it 'allows limiting parameter values' do
      command = COMMAND.new(parameters: { lmtd: { allowed: ['foo'] } })

      expect(parser.parse!(command, ['--lmtd', 'foo'])).to eq(lmtd: 'foo')
    end

    it 'ignores limiting values for missing optional parameters' do
      command = COMMAND.new(
        parameters: {
          lmtd: {
            allowed:  ['foo'],
            optional: true
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(lmtd: '')
    end

    it 'allows parameter alias values' do
      command = COMMAND.new(
        parameters: {
          alsd: {
            aliases: { 'foo' => 'bar', 'bar' => 'baz' }
          }
        }
      )

      expect(
        parser.parse!(command, ['--alsd=passthru'])
      ).to eq(alsd: 'passthru')

      expect(parser.parse!(command, ['--alsd=bar'])).to eq(alsd: 'baz')
      expect(parser.parse!(command, ['--alsd=foo'])).to eq(alsd: 'baz')
    end
  end

  describe 'with invalid parameter values' do
    it 'raises an ArgumentError' do
      command = COMMAND.new(parameters: { lmtd: { allowed: ['foo'] } })

      expect { parser.parse!(command, ['--lmtd', 'bar']) }.to(
        raise_error(ArgumentError)
      )
    end

    it 'raises an ArgumentError before escaping' do
      command = COMMAND.new(
        parameters: {
          lmtd: {
            allowed: ['fump'],
            escape:  { 'm' => 'u' }
          }
        }
      )

      expect { parser.parse!(command, ['--lmtd', 'fmp']) }.to(
        raise_error(ArgumentError)
      )
    end
  end
end
