require 'rails_helper'

RSpec.describe BecSopReferenceSwitch do
  subject { described_class }

  describe '#use_new_reference_type' do
    subject do
      Timecop.freeze(current_time) do
        described_class.use_new_reference_type
      end
    end

    context 'when called after the set date' do
      let(:current_time) { reference_change_date }

      it { is_expected.to eql true }
    end

    context 'when called before the set date' do
      let(:current_time) { reference_change_date - 1.day }

      it { is_expected.to eql false }
    end
  end
end
