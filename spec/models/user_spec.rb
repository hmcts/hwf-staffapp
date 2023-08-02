# coding: utf-8

require 'rails_helper'

describe User do

  let(:user)          { build(:user) }
  let(:manager)       { build(:manager) }
  let(:admin_user)    { build(:admin_user) }
  let(:mi)            { build(:mi) }
  let(:reader)        { build(:reader) }

  it { is_expected.to have_many(:applications) }
  it { is_expected.to have_many(:benefit_checks) }

  it 'pass factory build' do
    expect(user).to be_valid
  end

  describe 'scopes' do
    describe 'by_office' do
      let(:office1) { create(:office) }
      let(:office2) { create(:office) }

      before do
        described_class.delete_all
        create(:user, office: office1)
        create_list(:user, 3, office: office2)
      end

      describe 'filters users by office' do
        it { expect(described_class.by_office(office1).count).to eq 1 }
        it { expect(described_class.by_office(office2).count).to eq 3 }
      end
    end
  end

  describe 'responds to' do
    it 'jurisdiction' do
      expect(user).to respond_to :jurisdiction
    end
  end

  describe 'validations' do
    context 'email' do
      it 'require an email' do
        user.email = nil
        expect(user).not_to be_valid
      end

      it 'require a valid email' do
        user.email = 'testemail'
        expect(user).not_to be_valid
      end

      it 'require a unique email' do
        original = create(:user)
        duplicate = build(:user)
        duplicate.email = original.email
        expect(duplicate).not_to be_valid
      end

      context '(hmcts.gsi|digital.justice).gov.uk email addresses' do
        let(:user) { build(:user) }

        it 'requires only whitelisted email addresses' do
          expect(user).to be_valid
        end

        it 'allows hmcourts-service emails' do
          user.email = 'test.user@hmcourts-service.gsi.gov.uk'
          expect(user).to be_valid
        end

        it 'allows hmcts.net' do
          user.email = 'test.user@hmcts.net'
          expect(user).to be_valid
        end

        it 'allows @justice.gov.uk' do
          user.email = 'test.user@justice.gov.uk'
          expect(user).to be_valid
        end

        context 'non white listed emails' do
          let(:invalid_email) { 'email.that.rocks@gmail.com' }
          before { user.email = invalid_email }
          error_message = I18n.t('activerecord.errors.models.user.attributes.email.invalid_email', email: Settings.mail.tech_support)

          it 'will not accept non white listed emails' do
            expect(user).not_to be_valid
          end

          it 'has an informative error message for non white listed emails' do
            user.valid?
            expect(user.errors.messages[:email].first).to match error_message
          end
        end
      end
    end

    it 'requires a name' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'require a minimum 8 character password' do
      user.password = 'aabbcc'
      expect(user).not_to be_valid
    end

    describe 'require a non-nil role' do
      before do
        user.role = nil
        user.valid?
      end

      it { expect(user).not_to be_valid }
      it { expect(user.errors[:role]).to eq ["can't be blank"] }
    end

    describe 'require a valid role' do
      before do
        user.role = 'student'
        user.valid?
      end

      it { expect(user).not_to be_valid }
      it { expect(user.errors[:role]).to eq ["student is not a valid role"] }
    end

    describe 'jurisdiction' do
      describe 'must be valid' do
        before do
          user.jurisdiction_id = -999
          user.valid?
        end

        it { expect(user).not_to be_valid }
        it { expect(user.errors[:jurisdiction]).to eq ["Jurisdiction must exist"] }
      end

      it 'may be nil' do
        user.jurisdiction = nil
        expect(user).to be_valid
      end
    end
  end

  describe '@elevated?' do
    it { expect(manager.elevated?).to be true }
    it { expect(admin_user.elevated?).to be true }
    it { expect(user.elevated?).to be false }
    it { expect(reader.elevated?).to be false }
    it { expect(mi.elevated?).to be false }
  end

  describe '#staff?' do
    it { expect(user.staff?).to be true }
    it { expect(reader.staff?).to be false }
    it { expect(manager.staff?).to be false }
    it { expect(mi.staff?).to be false }
    it { expect(admin_user.staff?).to be false }
  end

  describe '@manager?' do
    it { expect(user.manager?).to be false }
    it { expect(reader.manager?).to be false }
    it { expect(manager.manager?).to be true }
    it { expect(mi.manager?).to be false }
    it { expect(admin_user.manager?).to be false }
  end

  describe '@admin?' do
    it { expect(user.admin?).to be false }
    it { expect(reader.admin?).to be false }
    it { expect(manager.admin?).to be false }
    it { expect(mi.admin?).to be false }
    it { expect(admin_user.admin?).to be true }
  end

  describe '#mi?' do
    it { expect(user.mi?).to be false }
    it { expect(reader.mi?).to be false }
    it { expect(manager.mi?).to be false }
    it { expect(mi.mi?).to be true }
    it { expect(admin_user.mi?).to be false }
  end

  describe '#reader?' do
    it { expect(user.reader?).to be false }
    it { expect(reader.reader?).to be true }
    it { expect(manager.reader?).to be false }
    it { expect(mi.reader?).to be false }
    it { expect(admin_user.reader?).to be false }
  end

  describe 'soft deletion' do
    before { [admin_user, mi, manager, user, reader].map(&:save) }

    context 'to start off' do
      it 'will have 5 users' do
        expect(described_class.count).to eq 5
      end
    end

    context 'when soft deleted' do
      before { user.destroy }

      it 'removes the user from the default scope' do
        expect(described_class.count).to eq 4
      end

      it 'throws an error when using the default scope' do
        expect { described_class.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'still keeps the user information around' do
        expect(described_class.with_deleted.find(user.id)).to eq user
      end
    end
  end

  describe '#activity_flag' do
    it 'returns :active for users logged in within last 3 months' do
      user.current_sign_in_at = 10.days.ago
      expect(user.activity_flag).to eq :active
    end

    it 'returns :inactive for users not logged in within last 3 months' do
      user.current_sign_in_at = 4.months.ago
      expect(user.activity_flag).to eq :inactive
    end

    it 'returns :inactive for users not logged in to the system at all' do
      user.current_sign_in_at = nil
      expect(user.activity_flag).to eq :inactive
    end
  end
end
