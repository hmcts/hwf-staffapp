require 'rails_helper'

RSpec.describe Forms::Application::Declaration do
  subject { described_class.new(detail) }

  let(:detail) { build(:detail, application: application) }
  let(:application) { build(:application) }

  params_list = [:discretion_applied, :statement_signed_by]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:statement_signed_by) }
  end

  describe '#save' do
    subject(:form) { described_class.new(detail) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    describe 'reset representative' do
      let(:representative) { create(:representative, application: application) }
      before do
        representative
      end

      context 'signed by applicant' do
        let(:params) { { statement_signed_by: 'applicant' } }

        it 'no representative' do
          expect(detail.application.representative).to eq representative
          update_form
          detail.reload

          expect(detail.application.representative).to be_nil
        end
      end

      context 'signed by legal_representative' do
        let(:params) { { statement_signed_by: 'legal_representative' } }

        it 'no representative' do
          expect(detail.application.representative).to eq representative
          update_form
          detail.reload

          expect(detail.application.representative).to eq representative
        end
      end
    end

    context 'when attributes are correct' do
      let(:params) { { statement_signed_by: 'applicant' } }

      it { is_expected.to be true }

      before do
        update_form
        detail.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(detail.send(key)).to eql(value)
        end
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { statement_signed_by: nil } }

      it { is_expected.to be false }
    end
  end
end
