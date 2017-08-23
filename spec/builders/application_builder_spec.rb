require 'rails_helper'

RSpec.describe ApplicationBuilder do

  let(:user) { create :user }
  let(:application_builder) { described_class.new(user) }
  let(:entity_code) { user.office.entity_code }
  let(:current_time) { Time.zone.now }
  let(:current_year) { current_time.strftime('%y') }
  let(:counter) do
    Reference.where("reference like ?", "#{entity_code}-#{current_year}-%").count + 1
  end

  describe '#build' do
    subject(:build_result) do
      Timecop.freeze(current_time) do
        application_builder.build
      end
    end

    describe 'builds and returns non persisted Application' do
      it { is_expected.to be_a(Application) }
      it { is_expected.not_to be_persisted }
    end

    describe 'the application' do
      it 'has the user stored' do
        expect(build_result.user).to eql(user)
      end

      it 'has office assigned from the user' do
        expect(build_result.office).to eql(user.office)
      end

      describe 'has applicant record built' do
        it { expect(build_result.applicant).to be_a(Applicant) }
        it { expect(build_result.applicant).not_to be_persisted }
      end

      describe 'has detail record built' do
        it { expect(build_result.detail).to be_a(Detail) }
        it { expect(build_result.detail).not_to be_persisted }
      end

      describe 'has saving record built' do
        it { expect(build_result.saving).to be_a(Saving) }
        it { expect(build_result.saving).not_to be_persisted }
      end

      it 'has jurisdiction assigned to the detail from the user' do
        expect(build_result.detail.jurisdiction).to eql(user.jurisdiction)
      end

      it 'does not have reference set' do
        expect(build_result.reference).to be nil
      end
    end
  end

  describe '#build_from' do
    subject(:built_application) do
      Timecop.freeze(current_time) do
        application_builder.build_from(online_application)
      end
    end

    let(:online_application) { build_stubbed(:online_application_with_all_details, :with_reference, :completed) }

    describe 'builds and returns non persisted Application' do
      it { is_expected.to be_a(Application) }
      it { is_expected.not_to be_persisted }
    end

    describe 'the application' do
      it 'has the user stored' do
        expect(built_application.user).to eql(user)
      end

      it 'has office assigned from the user' do
        expect(built_application.office).to eql(user.office)
      end

      it 'references the online application' do
        expect(built_application.online_application).to eql(online_application)
      end

      it 'has reference from the online application' do
        expect(built_application.reference).to eql(online_application.reference)
      end

      it 'sets the current min_thresholds' do
        expect(built_application.saving.min_threshold).to eql(Settings.savings_threshold.minimum)
      end

      it 'sets the current max_thresholds' do
        expect(built_application.saving.max_threshold).to eql(Settings.savings_threshold.maximum)
      end

      [:benefits, :income].each do |column|
        it "has #{column} assigned" do
          expect(built_application.public_send(column)).to eql(online_application.public_send(column))
        end
      end

      context 'when the online application has income thresholds instead of income' do
        context 'when the minimum threshold has not been exceeded' do
          let(:online_application) { build_stubbed(:online_application_with_all_details, :with_reference, :completed, income: nil, income_min_threshold_exceeded: false) }

          it 'has income_min_threshold_exceeded assigned' do
            expect(built_application.income_min_threshold_exceeded).to be false
          end
        end

        context 'when the maximum threshold has been exceeded' do
          let(:online_application) { build_stubbed(:online_application_with_all_details, :with_reference, :completed, income: nil, income_max_threshold_exceeded: true) }

          it 'has income_max_threshold_exceeded assigned' do
            expect(built_application.income_max_threshold_exceeded).to be true
          end
        end
      end

      context 'when the online application has children' do
        let(:online_application) { build_stubbed(:online_application_with_all_details, children: 2) }

        it 'has the dependents flag set to true' do
          expect(built_application.dependents).to be true
        end

        it 'has the children number set' do
          expect(built_application.children).to eq 2
        end
      end

      context 'when the online application does not have children' do
        let(:online_application) { build_stubbed(:online_application_with_all_details, children: 0) }

        it 'has the dependents flag set to false' do
          expect(built_application.dependents).to be false
        end

        it 'has the children number set as 0' do
          expect(built_application.children).to eq 0
        end
      end

      context 'when the online application does not specify children' do
        let(:online_application) { build_stubbed(:online_application_with_all_details, children: nil) }

        it 'has the dependents flag not to be set' do
          expect(built_application.dependents).to be nil
        end

        it 'has the children number set as nil' do
          expect(built_application.children).to be nil
        end
      end

      describe 'has applicant record built' do
        it { expect(built_application.applicant).to be_a(Applicant) }
        it { expect(built_application.applicant).not_to be_persisted }
      end

      describe 'the applicant' do
        subject(:built_applicant) { built_application.applicant }

        [:title, :first_name, :last_name, :date_of_birth, :ni_number, :married].each do |column|
          it "has #{column} assigned" do
            expect(built_applicant.public_send(column)).to eql(online_application.public_send(column))
          end
        end
      end

      describe 'has detail record built' do
        it { expect(built_application.detail).to be_a(Detail) }
        it { expect(built_application.detail).not_to be_persisted }
      end

      describe 'the detail' do
        subject(:built_detail) { built_application.detail }

        [:fee, :jurisdiction, :date_received, :form_name, :case_number, :probate, :deceased_name, :date_of_death, :refund, :date_fee_paid, :emergency_reason].each do |column|
          it "has #{column} assigned" do
            expect(built_detail.public_send(column)).to eql(online_application.public_send(column))
          end
        end
      end

      describe 'has savings record built' do
        it { expect(built_application.saving).to be_a(Saving) }
        it { expect(built_application.saving).not_to be_persisted }
      end

      describe 'the saving' do
        subject(:built_saving) { built_application.saving }

        [:min_threshold_exceeded, :max_threshold_exceeded, :amount, :over_61].each do |column|
          it "has #{column} assigned" do
            expect(built_saving.public_send(column)).to eql(online_application.public_send(column))
          end
        end
      end
    end
  end
end
