require 'rails_helper'

RSpec.describe Forms::Application::Delete do
  subject(:form) { described_class.new(application) }

  params_list = [:deleted_reasons_list, :deleted_reason]

  let(:application) { create(:application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:deleted_reasons_list) }
  end

  describe '#save' do
    subject(:form_save) do
      form.update(attributes)
      form.save
    end

    let(:attributes) { { deleted_reasons_list: reasons_list, deleted_reason: reason } }
    let(:application) { create(:application, deleted_reasons_list: nil, deleted_reason: nil) }

    context 'when the attributes are correct' do
      let(:reasons_list) { 'SOME REASON LIST' }
      let(:reason) { 'SOME REASON' }

      it { is_expected.to be true }

      it 'updates the deleted_reason field on the application' do
        form_save
        application.reload

        expect(application.deleted_reasons_list).to eql(reasons_list)
        expect(application.deleted_reason).to eql(reason)
      end
    end

    context 'when the attributes are incorrect' do
      let(:reasons_list) { nil }
      let(:reason) { nil }

      it { is_expected.to be false }
    end

    context 'when a reason is mandatory and no reason present' do
      let(:reasons_list) { 'Other error made by office processing application' }
      let(:reason) { nil }

      it { is_expected.to be false }
    end

    context 'when a reason is mandatory and reason is present' do
      let(:reasons_list) { 'Other error made by office processing application' }
      let(:reason) { 'SOME REASON' }

      it { is_expected.to be true }
    end
  end
end
