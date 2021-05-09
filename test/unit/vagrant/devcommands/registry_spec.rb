# frozen_string_literal: true

require_relative '../../../spec_helper'

describe VagrantPlugins::DevCommands::Registry do
  describe 'validating a reserved command' do
    it 'always returns true' do
      registry = described_class.new(nil)

      described_class::RESERVED_COMMANDS.each do |name|
        expect(registry.valid_command?(name)).to be true
      end
    end
  end
end
