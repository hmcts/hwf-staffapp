require 'rails_helper'

RSpec.describe Forms::OnlineApplication do
  params_list = %i[fee jurisdiction_id form_name emergency emergency_reason]

  let(:online_application) { build_stubbed :online_application }
  subject(:form) { described_class.new(online_application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:fee) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }

    describe 'emergency' do
      before do
        form.emergency = emergency
      end

      context 'when false' do
        let(:emergency) { false }

        it { is_expected.not_to validate_presence_of(:emergency_reason) }
      end

      context 'when true' do
        let(:emergency) { true }

        it { is_expected.to validate_presence_of(:emergency_reason) }
      end
    end
  end
end
