require 'rails_helper'

RSpec.describe Forms::FeeApproval do
  subject(:form) { described_class.new(online_application) }

  params_list = [:fee_manager_firstname, :fee_manager_lastname]

  let(:online_application) { create :online_application }

  describe '#permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee_manager_firstname) }
    it { is_expected.to validate_presence_of(:fee_manager_lastname) }
  end

  describe '#save' do
    subject(:form_save) { form.save }

    before do
      form.update_attributes(params)
    end

    context 'for an invalid form' do
      let(:params) { { fee_manager_firstname: nil, fee_manager_lastname: nil } }

      it { is_expected.to be false }
    end

    context 'for a valid form' do
      let(:params) { { fee_manager_firstname: 'Jane', fee_manager_lastname: 'Doe' } }

      it { is_expected.to be true }
    end
  end
end
