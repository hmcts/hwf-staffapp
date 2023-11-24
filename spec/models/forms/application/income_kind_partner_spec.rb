require 'rails_helper'

RSpec.describe Forms::Application::IncomeKindPartner do
  subject(:income_kind_form) { described_class.new(application) }
  let(:application) { build(:application) }

  params_list = [:income_kind, :income_kind_partner]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    let(:income_kind_form) { described_class.new(application) }

    describe 'income' do
      let(:application) { build(:application) }

      it { is_expected.to validate_presence_of(:income_kind_partner) }
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application, income_kind: { applicant: ['test'], partner: ['test2'] }) }

    context 'when attributes are correct' do
      let(:params) { { income_kind_partner: 'wages' } }

      it { is_expected.to be true }

      before do
        update_form
        application.reload
      end

      it 'saves the parameters in the detail' do
        expect(application.income_kind).to eq({ applicant: ['test'], partner: ['wages'] })
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { income_kind_partner: nil } }

      it { is_expected.to be false }
    end
  end

end
