require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Model::Chain do
  describe 'break_on_error configuration' do
    it 'defaults to false' do
      cmd = described_class.new({})

      expect(cmd.break_on_error?).to eq(true)
    end

    it 'allows configuration' do
      trueish  = described_class.new(break_on_error: :something_not_false)
      falseish = described_class.new(break_on_error: false)

      expect(trueish.break_on_error?).to eq(true)
      expect(falseish.break_on_error?).to eq(false)
    end
  end
end
