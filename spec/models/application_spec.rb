require 'rails_helper'
require 'support/calculator_test_data'

RSpec.describe Application, type: :model do
  subject(:application) { described_class.create(user_id: user.id, reference: attributes[:reference], applicant: applicant, detail: detail) }

  let(:user) { create :user }
  let(:attributes) { attributes_for :application }
  let(:applicant) { create(:applicant) }
  let(:detail) { create(:detail) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:applicant).dependent(:destroy) }
  it { is_expected.to have_one(:detail).dependent(:destroy) }

  it { is_expected.to have_one(:evidence_check).dependent(:destroy) }
  it { is_expected.not_to validate_presence_of(:evidence_check) }

  it { is_expected.to have_one(:part_payment).dependent(:destroy) }
  it { is_expected.not_to validate_presence_of(:part_payment) }

  it { is_expected.to validate_uniqueness_of(:reference).allow_blank }

  it { is_expected.to define_enum_for(:state).with_values([:created, :waiting_for_evidence, :waiting_for_part_payment, :processed, :deleted]) }

  it { is_expected.to have_many(:benefit_checks).dependent(:destroy) }
  it { is_expected.to have_one(:saving).dependent(:destroy) }
  it { is_expected.to have_one(:benefit_override).dependent(:destroy) }
  it { is_expected.to have_one(:decision_override).dependent(:destroy) }

  it { expect(application.purged).to be false }

  describe 'with_evidence_check_for_ni_number' do
    context 'pending evidence check' do
      let(:application) { create(:application, :waiting_for_evidence_state, applicant: applicant) }
      let(:applicant) { create(:applicant, ni_number: ni_number) }
      let(:ni_number) { 'SN123456C' }

      it "matching NI number" do
        list = described_class.with_evidence_check_for_ni_number(ni_number)
        expect(list).to eq([application])
      end

      it "not matching NI number" do
        list = described_class.with_evidence_check_for_ni_number('SN123456D')
        expect(list).to eq([])
      end

      context 'missing evidence_check record' do
        let(:list) { described_class.with_evidence_check_for_ni_number(ni_number) }
        it 'when there is no ev check' do
          application.evidence_check.destroy
          expect(list).to eq([])
        end
      end
    end

    context 'different state' do
      let(:application) { create(:application, applicant: applicant) }
      let(:applicant) { create(:applicant, ni_number: ni_number) }
      let(:ni_number) { 'SN123456C' }

      context 'matching NI number' do
        let(:list) { described_class.with_evidence_check_for_ni_number(ni_number) }
        it { expect(list).to eq([]) }
      end

      context 'not matching NI number' do
        let(:list) { described_class.with_evidence_check_for_ni_number('SN123456D') }
        it { expect(list).to eq([]) }
      end
    end
  end

  describe 'with_evidence_check_for_ho_number' do
    context 'pending evidence check' do
      let(:application) { create(:application, :waiting_for_evidence_state, applicant: applicant) }
      let(:applicant) { create(:applicant, ho_number: ho_number) }
      let(:ho_number) { 'L123456' }

      it "matching HO number" do
        list = described_class.with_evidence_check_for_ho_number(ho_number)
        expect(list).to eq([application])
      end

      it "not matching HO number" do
        list = described_class.with_evidence_check_for_ho_number('L654321')
        expect(list).to eq([])
      end

      context 'missing evidence_check record' do
        let(:list) { described_class.with_evidence_check_for_ho_number(ho_number) }
        it 'when there is no ev check' do
          application.evidence_check.destroy
          expect(list).to eq([])
        end
      end
    end

    context 'different state' do
      let(:application) { create(:application, applicant: applicant) }
      let(:applicant) { create(:applicant, ho_number: ho_number) }
      let(:ho_number) { 'L123456' }

      context 'matching NI number' do
        let(:list) { described_class.with_evidence_check_for_ho_number(ho_number) }
        it { expect(list).to eq([]) }
      end

      context 'not matching NI number' do
        let(:list) { described_class.with_evidence_check_for_ho_number('L654321') }
        it { expect(list).to eq([]) }
      end
    end
  end

  describe 'benefit checks' do
    let(:be_check1) { create :benefit_check, application: application, benefits_valid: true, dwp_result: 'Yes' }
    let(:be_check2) { create :benefit_check, application: application, benefits_valid: false, dwp_result: 'No' }

    before do
      be_check1
      be_check2
    end

    it "last_benefit_check ordered by id" do
      expect(application.last_benefit_check).to eq(be_check2)
    end

    context 'empty check' do
      let(:be_check3) { create :benefit_check, application: application, benefits_valid: nil, dwp_result: nil }
      before { be_check3 }

      it "last_benefit_check without empty checks" do
        expect(application.last_benefit_check).to eq(be_check2)
      end
    end
  end

  describe 'income kind' do
    let(:application) { create :application, income_kind: { applicant: ['Wages'], partner: ['Child benefits'] } }

    it 'stores serialized hash' do
      expect(application.income_kind).to eql(applicant: ['Wages'], partner: ['Child benefits'])
    end
  end

  describe 'failed_because_dwp_error?' do
    before do
      create :benefit_check, application: application, benefits_valid: true, dwp_result: 'Yes'
    end

    it { expect(application.failed_because_dwp_error?).to be false }

    context 'failed response but not dwp down' do
      before do
        create :benefit_check, application: application, benefits_valid: false, dwp_result: 'Unspecified error', error_message: 'Server broke connection'
      end
      it { expect(application.failed_because_dwp_error?).to be false }
    end

    context 'failed response dwp down' do
      before do
        create :benefit_check, application: application, benefits_valid: false, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable'
      end
      it { expect(application.failed_because_dwp_error?).to be true }
    end

    context 'failed response dwp down as Server unavailable' do
      before do
        create :benefit_check, application: application, benefits_valid: false, dwp_result: 'Server unavailable', error_message: 'The benefits checker is not available at the moment. Please check again later.'
      end
      it { expect(application.failed_because_dwp_error?).to be true }
    end

    context 'failed response dwp down in past' do
      before do
        create :benefit_check, application: application, benefits_valid: false, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.'
        create :benefit_check, application: application, benefits_valid: false, dwp_result: 'Yes'
      end
      it { expect(application.failed_because_dwp_error?).to be false }
    end

  end

end
