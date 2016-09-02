require 'rails_helper'

RSpec.describe Views::ApplicationList do
  let(:user) { build :user }
  let(:applicant) { build(:applicant) }
  let(:detail) { build(:detail, date_received: '2015-10-01') }
  let(:completed_by) { user }
  let(:completed_at) { Date.new(2015, 10, 02) }

  context 'when initialized with an application' do
    let(:application) do
      build(:application, applicant: applicant, detail: detail, completed_by: completed_by, completed_at: completed_at)
    end

    subject(:view) { described_class.new(application) }

    describe '#id' do
      it 'returns the application id' do
        expect(view.id).to eql(application.id)
      end
    end

    describe '#reference' do
      it 'returns the application reference' do
        expect(view.reference).to eql(application.reference)
      end
    end

    describe '#applicant' do
      it 'returns the applicant\'s full name' do
        expect(view.applicant).to eql(applicant.full_name)
      end
    end

    describe '#date_received' do
      it 'returns formatted date of application received date' do
        expect(view.date_received).to eql('1 October 2015')
      end
    end

    describe '#processed_by' do
      subject { view.processed_by }

      context 'when completed_by is set' do
        it 'returns the name of the user who completed the application' do
          is_expected.to eql(application.completed_by.name)
        end
      end

      context 'when completed_by is nil' do
        let(:completed_by) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    describe '#processed_on' do
      subject { view.processed_on }

      context 'when processed_on is set' do
        it 'returns the date the application was completed' do
          is_expected.to eql('2 October 2015')
        end
      end

      context 'when processed_on is nil' do
        let(:completed_at) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    describe '#form_name' do
      let(:detail) { build(:detail, form_name: 'NAME') }

      subject { view.form_name }

      it 'returns the form name from the detail' do
        is_expected.to eql('NAME')
      end
    end

    describe '#fee' do
      let(:detail) { build(:detail, fee: 3913) }

      subject { view.fee }

      it 'returns the fee formatted as a currency' do
        is_expected.to eql('£3,913')
      end
    end

    describe '#emergency' do
      let(:detail) { build(:detail, emergency_reason: emergency_reason) }

      subject { view.emergency }

      context 'when emergency reason is empty' do
        let(:emergency_reason) { nil }

        it 'returns empty string' do
          is_expected.to eql ''
        end
      end

      context 'when emergency reason is set' do
        let(:emergency_reason) { 'some reason' }

        it 'returns Yes' do
          is_expected.to eql 'Yes'
        end
      end
    end

    describe '#@evidence_or_part_payment' do
      subject { view.evidence_or_part_payment }

      it { is_expected.to be nil }
    end
  end

  context 'when initialized with a part-payment' do
    let(:application) { build :application_part_remission, :waiting_for_part_payment_state, applicant: applicant, detail: detail, completed_by: completed_by, completed_at: completed_at }
    let(:part_payment) { build :part_payment, application: application }

    subject(:view) { described_class.new(part_payment) }

    describe '#id' do
      it 'returns the application id' do
        expect(view.id).to eql(application.id)
      end
    end

    describe '#reference' do
      it 'returns the application reference' do
        expect(view.reference).to eql(application.reference)
      end
    end

    describe '#applicant' do
      it 'returns the applicant\'s full name' do
        expect(view.applicant).to eql(applicant.full_name)
      end
    end

    describe '#date_received' do
      it 'returns formatted date of application received date' do
        expect(view.date_received).to eql('1 October 2015')
      end
    end

    describe '#processed_by' do
      subject { view.processed_by }

      context 'when completed_by is set' do
        it 'returns the name of the user who completed the application' do
          is_expected.to eql(application.completed_by.name)
        end
      end

      context 'when completed_by is nil' do
        let(:completed_by) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    describe '#processed_on' do
      subject { view.processed_on }

      context 'when processed_on is set' do
        it 'returns the date the application was completed' do
          is_expected.to eql('2 October 2015')
        end
      end

      context 'when processed_on is nil' do
        let(:completed_at) { nil }

        it 'returns nil' do
          is_expected.to be nil
        end
      end
    end

    describe '#form_name' do
      let(:detail) { build(:detail, form_name: 'NAME') }

      subject { view.form_name }

      it 'returns the form name from the detail' do
        is_expected.to eql('NAME')
      end
    end

    describe '#fee' do
      let(:detail) { build(:detail, fee: 3913) }

      subject { view.fee }

      it 'returns the fee formatted as a currency' do
        is_expected.to eql('£3,913')
      end
    end

    describe '#emergency' do
      let(:detail) { build(:detail, emergency_reason: emergency_reason) }

      subject { view.emergency }

      context 'when emergency reason is empty' do
        let(:emergency_reason) { nil }

        it 'returns empty string' do
          is_expected.to eql ''
        end
      end

      context 'when emergency reason is set' do
        let(:emergency_reason) { 'some reason' }

        it 'returns Yes' do
          is_expected.to eql 'Yes'
        end
      end
    end

    describe '#@evidence_or_part_payment' do
      subject { view.evidence_or_part_payment }

      it { is_expected.to eq part_payment }
    end
  end
end
