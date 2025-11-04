require 'rails_helper'

RSpec.describe OnlineApplication do
  subject(:online_application) { online_application }
  let(:online_application) { build(:online_application) }

  it { is_expected.to validate_presence_of(:date_of_birth) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_presence_of(:postcode) }

  it { is_expected.not_to allow_value(nil).for(:married) }
  it { is_expected.not_to allow_value(nil).for(:min_threshold_exceeded) }
  it { is_expected.not_to allow_value(nil).for(:benefits) }
  it { is_expected.not_to allow_value(nil).for(:refund) }
  it { is_expected.not_to allow_value(nil).for(:email_contact) }
  it { is_expected.not_to allow_value(nil).for(:phone_contact) }
  it { is_expected.not_to allow_value(nil).for(:post_contact) }
  it { is_expected.not_to allow_value(nil).for(:feedback_opt_in) }

  it { is_expected.to allow_value(nil).for(:probate) }

  it { is_expected.to validate_uniqueness_of(:reference) }

  it { expect(online_application.purged).to be false }

  describe '#ni_number validation' do
    context 'ho_number and ni_number is empty' do
      before { online_application.ni_number = nil }

      it { is_expected.not_to be_valid }
    end

    context 'ho_number has a value and ni_number is empty' do
      before do
        online_application.ni_number = nil
        online_application.ho_number = 'L123456'
      end

      it { is_expected.to be_valid }
    end

    context 'ho_number in empty and ni_number is is valid' do
      before do
        online_application.ni_number = 'SN123456C'
        online_application.ho_number = nil
      end

      it { is_expected.to be_valid }
    end

    context 'over_16 when no NI and no HO' do
      before do
        online_application.ni_number = nil
        online_application.ho_number = nil
        online_application.over_16 = false
      end

      it { is_expected.to be_valid }
    end
  end

  describe '#full_name' do
    subject { online_application.full_name }

    let(:online_application) { build(:online_application, first_name: 'Mary', last_name: 'Smith', title: title) }

    context 'when title is present' do
      let(:title) { 'Mrs.' }

      it 'returns title, first_name and last_name separated by spaced' do
        is_expected.to eql('Mrs. Mary Smith')
      end
    end

    context 'when title is not present' do
      let(:title) { nil }

      it 'returns first_name and last_name separated by spaced' do
        is_expected.to eql('Mary Smith')
      end
    end
  end

  describe '#processed?' do

    subject { online_application.processed? }

    context 'when an application exists that is linked to this online_application' do
      let(:online_application) { create(:online_application, :completed, :with_reference, convert_to_application: true) }

      it { is_expected.to be true }
    end

    context 'when no application exists that is linked to this online_application' do
      let(:online_application) { create(:online_application, :completed, :with_reference) }

      it { is_expected.to be false }
    end

    context 'when application exists but it is still in created mode' do
      let(:application) { create(:application, online_application: online_application) }
      let(:online_application) { create(:online_application, :completed, :with_reference) }
      before { application }

      it { is_expected.to be false }
    end
  end

  describe '#linked_application' do

    subject(:linked_application) { online_application.linked_application }

    context 'when an application exists that is linked to this online_application' do
      let(:online_application) { create(:online_application, :completed, :with_reference, convert_to_application: true) }

      it { is_expected.to eql Application.find_by(reference: online_application.reference) }
    end

    context 'when no application exists that is linked to this online_application' do
      let(:online_application) { create(:online_application, :completed, :with_reference) }

      it { is_expected.to be_nil }
    end

    context 'when linked application is "purged"' do
      let(:online_application) { create(:online_application, :completed, :with_reference, convert_to_application: true) }

      it "returns nil" do
        linked_application.update(purged: true)
        expect(online_application.linked_application).to be_nil
      end

      it "returns purged application" do
        linked_application.update(purged: true)
        expect(online_application.linked_application(:with_purged)).not_to be_nil
      end
    end
  end

  describe 'income kind' do
    before do
      online_application.income_kind = { applicant: ['Wages'], partner: ['Child benefits'] }
      online_application.save
    end

    it 'stores serialized hash' do
      expect(online_application.reload.income_kind).to eql(applicant: ['Wages'], partner: ['Child benefits'])
    end
  end

  describe 'applicant' do
    let(:online_application) { build(:online_application, title: 'Mr', first_name: 'James', last_name: 'Grump') }

    it 'is an Applicant model object' do
      expect(online_application.applicant).to be_a(Applicant)
    end

    it 'has correct data' do
      expect(online_application.applicant.full_name).to eq('Mr James Grump')
    end

    it 'has methods related to applicant' do
      expect(online_application.applicant.under_age?).to be false
    end
  end

  describe 'purged application' do
    it {
      create(:online_application, purged: true)
      expect(described_class.count).to eq 0
    }
  end

  describe 'not purged application' do
    it {
      create(:online_application, purged: false)
      expect(described_class.count).to eq 1
    }
  end

  describe '#notification_email' do
    subject { online_application.notification_email }
    let(:online_application) { build(:online_application, email_address: applicant_address, legal_representative_email: legal_representative_email) }
    let(:applicant_address) { 'jane@home.com' }

    context 'when no representative email' do
      let(:legal_representative_email) { '' }

      it "returns applicant's email" do
        is_expected.to eql('jane@home.com')
      end
    end

    context 'when epresentative email present' do
      let(:legal_representative_email) { 'tom@work.com' }

      it "returns legal representative's email" do
        is_expected.to eql('tom@work.com')
      end
    end
  end

  context 'partner' do
    let(:online_application) { build(:online_application, partner_first_name: 'John', partner_last_name: 'Doe', partner_date_of_birth: Date.new(2000, 2, 1), partner_ni_number: 'CD789012E') }

    describe '#partner_full_name' do
      it 'returns the full name of the partner' do
        expect(online_application.partner_full_name).to eq('John Doe')
      end

      it 'returns nil if partner first name is nil' do
        online_application.partner_first_name = nil
        expect(online_application.partner_full_name).to eq('Doe')
      end

      it 'returns nil if partner last name is nil' do
        online_application.partner_last_name = nil
        expect(online_application.partner_full_name).to eq('John')
      end
    end

    describe '#formated_partner_date_of_birth' do
      it 'returns the formated date of birth of the partner' do
        expect(online_application.formated_partner_date_of_birth).to eq('1 February 2000')
      end

      it 'returns nil if partner date of birth is nil' do
        online_application.partner_date_of_birth = nil
        expect(online_application.formated_partner_date_of_birth).to be_nil
      end
    end

    describe '#formated_partner_ni_number' do
      it 'returns the formatted NI number of the partner' do
        expect(online_application.formated_partner_ni_number).to eq('CD 78 90 12 E')
      end

      it 'returns nil if partner NI number is nil' do
        online_application.partner_ni_number = nil
        expect(online_application.formated_partner_ni_number).to be_nil
      end
    end
  end

  describe '#benefit_check_with_error_message?' do
    let(:online_application) { create(:online_application) }

    it 'returns false when there is no benefit check' do
      expect(online_application.benefit_check_with_error_message?).to be false
    end

    it 'returns true when last benefit check has error message' do
      create(:benefit_check, applicationable: online_application, benefits_valid: false, dwp_result: 'Unspecified error', error_message: 'some error')
      expect(online_application.reload.benefit_check_with_error_message?).to be true
    end

    it 'returns false when last benefit check has dwp_result No' do
      create(:benefit_check, applicationable: online_application, benefits_valid: false, dwp_result: 'No')
      expect(online_application.reload.benefit_check_with_error_message?).to be false
    end

    it 'returns false when last benefit check has dwp_result Yes' do
      create(:benefit_check, applicationable: online_application, benefits_valid: true, dwp_result: 'Yes')
      expect(online_application.reload.benefit_check_with_error_message?).to be false
    end
  end

  describe '#allow_benefit_check_override?' do
    let(:online_application) { create(:online_application) }

    it 'returns false when there is no benefit check' do
      expect(online_application.allow_benefit_check_override?).to be false
    end

    it 'returns true when last benefit check has error message' do
      create(:benefit_check, applicationable: online_application, benefits_valid: false, dwp_result: 'Unspecified error', error_message: 'some error')
      expect(online_application.reload.allow_benefit_check_override?).to be true
    end

    it 'returns true when last benefit check has dwp_result No' do
      create(:benefit_check, applicationable: online_application, benefits_valid: false, dwp_result: 'No', error_message: nil)
      expect(online_application.reload.allow_benefit_check_override?).to be true
    end

    it 'returns false when last benefit check has dwp_result Yes' do
      create(:benefit_check, applicationable: online_application, benefits_valid: true, dwp_result: 'Yes')
      expect(online_application.reload.allow_benefit_check_override?).to be false
    end
  end

end
