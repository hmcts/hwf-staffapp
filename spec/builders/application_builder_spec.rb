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

      it 'has jurisdiction assigned to the detail from the user' do
        expect(subject.detail.jurisdiction).to eql(user.jurisdiction)
      end

      it 'does not have reference set' do
        expect(subject.reference).to be nil
      end
    end
  end
end
