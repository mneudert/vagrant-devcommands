require_relative '../../../../spec_helper'

describe VagrantPlugins::DevCommands::Util::JaroWinkler do
  # https://github.com/bbatsov/rubocop/blob/16531bf5c308af1093aa710807f4465254c9e470/spec/rubocop/string_util_spec.rb
  {
    %w[al al] => 1.000,
    %w[martha marhta] => 0.961,
    %w[jones johnson] => 0.832,
    %w[abcvwxyz cabvwxyz] => 0.958,
    %w[dwayne duane] => 0.840,
    %w[dixon dicksonx] => 0.813,
    %w[fvie ten] => 0.000
  }.each do |strings, expected|
    context "with #{strings.first.inspect} and #{strings.last.inspect}" do
      subject(:distance) { described_class.new(*strings).distance }

      it "returns #{expected}" do
        expect(distance).to be_within(0.001).of(expected)
      end
    end
  end
end
