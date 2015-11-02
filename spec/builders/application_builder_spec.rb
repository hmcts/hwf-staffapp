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

  describe '#create' do
    subject(:create_result) do
      Timecop.freeze(current_time) do
        application_builder.create
      end
    end

    it 'creates and returns Application' do
      is_expected.to be_a(Application)
      is_expected.to be_persisted
    end

    describe 'the application' do
      it 'has the user stored' do
        expect(subject.user).to eql(user)
      end

      it 'has office assigned from the user' do
        expect(subject.office).to eql(user.office)
      end

      it 'has applicant record created' do
        expect(subject.applicant).to be_a(Applicant)
        expect(subject.applicant).to be_persisted
      end

      it 'has detail record created' do
        expect(subject.detail).to be_a(Detail)
        expect(subject.detail).to be_persisted
      end

      it 'has jurisdiction assigned to the detail from the user' do
        expect(subject.detail.jurisdiction).to eql(user.jurisdiction)
      end

      describe 'the generated reference' do
        subject(:reference) { create_result.reference }

        it 'starts with the office entity code' do
          is_expected.to match(/^#{user.office.entity_code}/)
        end

        it 'contains the current year' do
          is_expected.to match(/-#{current_year}-/)
        end

        it 'increments counter for the same office and year' do
          first_reference = application_builder.create.reference
          first_counter = /-([0-9]+)$/.match(first_reference)[1].to_i

          second_reference = subject
          second_counter = /-([0-9]+)$/.match(second_reference)[1].to_i

          expect(second_counter - first_counter).to be(1)
        end
      end
    end
  end
end
