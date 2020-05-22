require 'rails_helper'

RSpec.describe Forms::OnlineApplication do
  subject(:form) { described_class.new(online_application) }

  params_list = [:fee, :jurisdiction_id, :benefits_override, :date_received, :day_date_received, :month_date_received, :year_date_received, :form_name, :emergency, :emergency_reason]

  let(:online_application) { build_stubbed :online_application }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe '#initialize' do
    let(:online_application) { build_stubbed :online_application, emergency_reason: emergency_reason }

    context 'when the online application has emergency reason' do
      let(:emergency_reason) { 'REASON' }

      it 'assigns true to the emergency field' do
        expect(form.emergency).to be true
      end
    end

    context 'when the online application does not have emergency reason' do
      let(:emergency_reason) { nil }

      it 'keeps the emergency field nil' do
        expect(form.emergency).to be nil
      end
    end
  end

  describe '#enable_default_jurisdiction' do
    subject { form.jurisdiction_id }

    let(:user) { create :staff, jurisdiction: jurisdiction }

    before { form.enable_default_jurisdiction(user) }

    context 'when the user has no default jurisdiction' do
      let(:jurisdiction) { nil }

      it { is_expected.to eq nil }
    end

    context 'when the user has a default jurisdiction' do
      let(:jurisdiction) { create :jurisdiction }

      it { is_expected.to eq jurisdiction.id }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_numericality_of(:fee).is_less_than(20_000) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }
    it { is_expected.to validate_length_of(:emergency_reason).is_at_most(500) }

    describe 'date_received' do
      let(:online_application) { build_stubbed :online_application, :completed }

      include_examples 'date_received validation'
    end

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

    describe 'form_name' do
      let(:online_application) { build_stubbed :online_application, :completed, form_name: form_name }

      context 'EX160' do
        let(:form_name) { 'EX160' }

        it { is_expected.not_to be_valid }
      end

      context 'EX161' do
        let(:form_name) { 'EX161' }

        it { is_expected.to be_valid }
      end

      context "can't be blank" do
        let(:form_name) { '' }

        it { is_expected.not_to be_valid }
      end
    end

  end

  describe '#save' do
    subject do
      form.update_attributes(params)
      form.save
    end

    let(:online_application) { create :online_application }
    let(:jurisdiction) { create :jurisdiction }

    context 'when the params are correct' do
      let(:params) do
        {
          fee: 100,
          jurisdiction_id: jurisdiction.id,
          date_received: Time.zone.yesterday,
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
        [:fee, :jurisdiction_id, :date_received, :form_name, :emergency_reason].each do |key|
          it "has the correct :#{key}" do
            expect(reloaded_application.send(key)).to eql(params[key])
          end
        end
      end

      it { is_expected.to be true }

      describe 'when emergency is false but emergency_reason had been set' do
        let(:online_application) { create :online_application, emergency_reason: 'SOME REASON' }
        before do
          params[:emergency] = false
        end

        it 'clears the emergency reason' do
          expect(reloaded_application.emergency_reason).to be nil
        end
      end
    end

    context 'when the params are not correct' do
      let(:params) { {} }

      it { is_expected.to be false }
    end
  end
end
