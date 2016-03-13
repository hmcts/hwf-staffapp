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
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_numericality_of(:fee) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }
    it { is_expected.to validate_length_of(:emergency_reason).is_at_most(500) }

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

  describe '#save' do
    let(:online_application) { create :online_application }
    let(:jurisdiction) { create :jurisdiction }

    subject do
      form.update_attributes(params)
      form.save
    end

    context 'when the params are correct' do
      let(:params) do
        {
          fee: 100,
          jurisdiction_id: jurisdiction.id,
          form_name: 'E45',
          emergency: true,
          emergency_reason: 'SOME REASON'
        }
      end
      let(:reloaded_application) do
        subject
        online_application.reload
      end

      describe 'the saved online application' do
        [:fee, :jurisdiction_id, :form_name, :emergency_reason].each do |key|
          it "has the correct :#{key}" do
            expect(reloaded_application.send(key)).to eql(params[key])
          end
        end
      end

      it { is_expected.to be true }
    end

    context 'when the params are not correct' do
      let(:params) { {} }

      it { is_expected.to be false }
    end
  end
end
