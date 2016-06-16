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

    it 'builds and returns non persisted Application' do
      is_expected.to be_a(Application)
      is_expected.not_to be_persisted
    end

    describe 'the application' do
      it 'has the user stored' do
        expect(subject.user).to eql(user)
      end

      it 'has office assigned from the user' do
        expect(subject.office).to eql(user.office)
      end

      it 'has applicant record built' do
        expect(subject.applicant).to be_a(Applicant)
        expect(subject.applicant).not_to be_persisted
      end

      it 'has detail record built' do
        expect(subject.detail).to be_a(Detail)
        expect(subject.detail).not_to be_persisted
      end

      it 'has saving record built' do
        expect(subject.saving).to be_a(Saving)
        expect(subject.saving).not_to be_persisted
      end

      it 'has jurisdiction assigned to the detail from the user' do
        expect(subject.detail.jurisdiction).to eql(user.jurisdiction)
      end

      it 'does not have reference set' do
        expect(subject.reference).to be nil
      end
    end
  end

  describe '#build_from' do
    let(:online_application) { build_stubbed(:online_application_with_all_details, :with_reference, :completed) }

    subject(:built_application) do
      Timecop.freeze(current_time) do
        application_builder.build_from(online_application)
      end
    end

    it 'builds and returns non persisted Application' do
      is_expected.to be_a(Application)
      is_expected.not_to be_persisted
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

      %i[threshold_exceeded benefits income].each do |column|
        it "has #{column} assigned" do
          expect(built_application.public_send(column)).to eql(online_application.public_send(column))
        end
      end

      context 'when the online application has children' do
        let(:online_application) { build_stubbed(:online_application_with_all_details, children: 2) }

        it 'has the dependents flag set to true' do
          expect(built_application.dependents).to be true
        end

        it 'has the children number set' do
          expect(built_application.children).to eql(2)
        end
      end

      context 'when the online application does not have children' do
        let(:online_application) { build_stubbed(:online_application_with_all_details, children: 0) }

        it 'has the dependents flag set to false' do
          expect(built_application.dependents).to be false
        end

        it 'has the children number set as 0' do
          expect(built_application.children).to eql(0)
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

      it 'has applicant record built' do
        expect(built_application.applicant).to be_a(Applicant)
        expect(built_application.applicant).not_to be_persisted
      end

      describe 'the applicant' do
        subject(:built_applicant) { built_application.applicant }

        %i[title first_name last_name date_of_birth ni_number married].each do |column|
          it "has #{column} assigned" do
            expect(built_application.public_send(column)).to eql(online_application.public_send(column))
          end
        end
      end

      it 'has detail record built' do
        expect(built_application.detail).to be_a(Detail)
        expect(built_application.detail).not_to be_persisted
      end

      describe 'the detail' do
        subject(:built_detail) { built_application.detail }

        %i[fee jurisdiction date_received form_name case_number probate deceased_name date_of_death refund date_fee_paid emergency_reason].each do |column|
          it "has #{column} assigned" do
            expect(built_detail.public_send(column)).to eql(online_application.public_send(column))
          end
        end
      end
    end
  end
end
