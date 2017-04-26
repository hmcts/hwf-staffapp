require 'rails_helper'
require 'support/calculator_test_data'

RSpec.describe Application, type: :model do
  subject(:application) { described_class.create(user_id: user.id, reference: attributes[:reference], applicant: applicant, detail: detail) }

  let(:user) { create :user }
  let(:attributes) { attributes_for :application }
  let(:applicant) { create(:applicant) }
  let(:detail) { create(:detail) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:completed_by).class_name('User') }
  it { is_expected.to belong_to(:deleted_by).class_name('User') }
  it { is_expected.to belong_to(:office) }
  it { is_expected.to belong_to(:business_entity) }
  it { is_expected.to belong_to(:online_application) }

  it { is_expected.to have_one(:applicant) }
  it { is_expected.to have_one(:detail) }

  it { is_expected.to have_one(:evidence_check) }
  it { is_expected.not_to validate_presence_of(:evidence_check) }

  it { is_expected.to have_one(:part_payment) }
  it { is_expected.not_to validate_presence_of(:part_payment) }

  it { is_expected.to validate_uniqueness_of(:reference).allow_blank }

  it { is_expected.to define_enum_for(:state).with([:created, :waiting_for_evidence, :waiting_for_part_payment, :processed, :deleted]) }

  describe 'with_evidence_check_for_ni_number' do
    let(:evidence_check) { create(:evidence_check, application: application) }

    context 'pending evidence check' do
      let(:application) { create(:application, :waiting_for_evidence_state, applicant: applicant) }
      let(:applicant) { create(:applicant, ni_number: ni_number) }
      let(:ni_number) { 'SN123456C' }

      it "matching NI number" do
        evidence_check
        list = Application.with_evidence_check_for_ni_number(ni_number)
        expect(list).to eq([application])
      end

      it "not matching NI number" do
        evidence_check
        list = Application.with_evidence_check_for_ni_number('SN123456D')
        expect(list).to eq([])
      end

      it "missing evidence_check record" do
        list = Application.with_evidence_check_for_ni_number(ni_number)
        expect(list).to eq([])
      end
    end

    context 'different state' do
      let(:application) { create(:application, applicant: applicant) }
      let(:applicant) { create(:applicant, ni_number: ni_number) }
      let(:ni_number) { 'SN123456C' }
      before { evidence_check }

      it "matching NI number" do
        list = Application.with_evidence_check_for_ni_number(ni_number)
        expect(list).to eq([])
      end

      it "not matching NI number" do
        list = Application.with_evidence_check_for_ni_number('SN123456D')
        expect(list).to eq([])
      end

      it "missing evidence_check record" do
        list = Application.with_evidence_check_for_ni_number(ni_number)
        expect(list).to eq([])
      end
    end
  end
end
