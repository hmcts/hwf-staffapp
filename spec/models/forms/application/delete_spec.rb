require 'rails_helper'

RSpec.describe Forms::Application::Delete do
  subject(:form) { described_class.new(application) }

  params_list = %i[deleted_reason]

  let(:application) { create :application }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:deleted_reason) }
  end

  describe '#save' do
    subject(:form_save) do
      form.update_attributes(attributes)
      form.save
    end

    let(:attributes) { { deleted_reason: reason } }
    let(:application) { create :application, deleted_reason: nil }

    context 'when the attributes are correct' do
      let(:reason) { 'SOME REASON' }

      it { is_expected.to be true }

      it 'updates the deleted_reason field on the application' do
        form_save
        application.reload

        expect(application.deleted_reason).to eql(reason)
      end
    end

    context 'when the attributes are incorrect' do
      let(:reason) { nil }

      it { is_expected.to be false }
    end
  end
end
