# frozen_string_literal: true

require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::ParamParser do
  command_model = VagrantPlugins::DevCommands::Model::Command

  let(:parser) { described_class.new }

  describe 'with configured parameters' do
    it 'allows optional parameters' do
      command = command_model.new(
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
      command = command_model.new(flags: { dflt: {} })

      expect(parser.parse!(command, [])).to eq(dflt: '')
      expect(parser.parse!(command, ['--dflt'])).to eq(dflt: '--dflt')
    end

    it 'allows flags with values' do
      command = command_model.new(flags: { dflt: { value: '--custom' } })

      expect(parser.parse!(command, ['--dflt'])).to eq(dflt: '--custom')
    end

    it 'allows escaping parameter values' do
      command = command_model.new(
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
      command = command_model.new(parameters: { dflt: { default: 'dflt' } })

      expect(parser.parse!(command, [])).to eq(dflt: 'dflt')
      expect(
        parser.parse!(command, ['--dflt', 'changed'])
      ).to eq(dflt: 'changed')
    end

    it 'allows parameter value wrapping' do
      command = command_model.new(parameters: { wrppd: { wrap: '--opt %s' } })

      expect(
        parser.parse!(command, ['--wrppd', 'custom'])
      ).to eq(wrppd: '--opt custom')
    end

    it 'does not wrap unpassed optional parameters' do
      command = command_model.new(
        parameters: {
          wrppd: {
            optional: true,
            wrap: '--opt %s'
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(wrppd: '')
    end

    it 'does wrap unpassed optional parameters with empty default' do
      command = command_model.new(
        parameters: {
          wrppd: {
            wrap: '--opt %s',
            default: ''
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(wrppd: '--opt ')
    end

    it 'allows limiting parameter values' do
      command = command_model.new(parameters: { lmtd: { allowed: ['foo'] } })

      expect(parser.parse!(command, ['--lmtd', 'foo'])).to eq(lmtd: 'foo')
    end

    it 'ignores limiting values for missing optional parameters' do
      command = command_model.new(
        parameters: {
          lmtd: {
            allowed: ['foo'],
            optional: true
          }
        }
      )

      expect(parser.parse!(command, [])).to eq(lmtd: '')
    end

    it 'allows parameter alias values' do
      command = command_model.new(
        parameters: {
          alsd: {
            aliases: { 'foo' => 'bar', 'bar' => 'baz' }
          }
        }
      )

      expect(parser.parse!(command, ['--alsd=pass'])).to eq(alsd: 'pass')
      expect(parser.parse!(command, ['--alsd=bar'])).to eq(alsd: 'baz')
      expect(parser.parse!(command, ['--alsd=foo'])).to eq(alsd: 'baz')
    end
  end

  describe 'with passthru parameter configured' do
    it 'passes unknown parameters' do
      command = command_model.new(
        parameters: {
          psthr: { passthru: true }
        }
      )

      expect(
        parser.parse!(command, ['--will=be --passed=on'])
      ).to eq(psthr: '--will=be --passed=on')
    end

    it 'properly parses known flags' do
      command = command_model.new(
        flags: { flggd: {} },
        parameters: { psthr: { passthru: true } }
      )

      expect(
        parser.parse!(command, ['--flggd', '--will=be', '--passed=on'])
      ).to eq(flggd: '--flggd', psthr: '--will=be --passed=on')
    end

    it 'properly parses known parameters' do
      command = command_model.new(
        parameters: {
          prsd: {},
          psthr: { passthru: true }
        }
      )

      expect(
        parser.parse!(command, ['--prsd=foo', '--will=be', '--passed=on'])
      ).to eq(prsd: 'foo', psthr: '--will=be --passed=on')
    end
  end

  describe 'with invalid parameter values' do
    it 'raises an ArgumentError' do
      command = command_model.new(parameters: { lmtd: { allowed: ['foo'] } })

      expect { parser.parse!(command, ['--lmtd', 'bar']) }.to(
        raise_error(ArgumentError)
      )
    end

    it 'raises an ArgumentError before escaping' do
      command = command_model.new(
        parameters: {
          lmtd: {
            allowed: ['fump'],
            escape: { 'm' => 'u' }
          }
        }
      )

      expect { parser.parse!(command, ['--lmtd', 'fmp']) }.to(
        raise_error(ArgumentError)
      )
    end
  end
end
