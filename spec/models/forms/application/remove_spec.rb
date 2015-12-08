require 'rails_helper'

RSpec.describe Forms::Application::Remove do
  params_list = %i[removed_reason]

  let(:application) { create :application }

  subject(:form) { described_class.new(application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:removed_reason) }
  end

  describe '#save' do
    let(:attributes) { { removed_reason: reason } }
    let(:application) { create :application, removed_reason: nil }

    subject do
      form.update_attributes(attributes)
      form.save
    end

    context 'when the attributes are correct' do
      let(:reason) { 'SOME REASON' }

      it { is_expected.to be true }

      it 'updates the removed_reason field on the application' do
        subject
        application.reload

        expect(application.removed_reason).to eql(reason)
      end
    end

    context 'when the attributes are incorrect' do
      let(:reason) { nil }

      it { is_expected.to be false }
    end
  end
end
