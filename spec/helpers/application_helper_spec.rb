require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#hide_login_menu?' do
    it 'false when visiting root path' do
      expect(helper.hide_login_menu?(root_path)).to be false
    end

    it 'true when visiting the sign in path' do
      expect(helper.hide_login_menu?(new_user_session_path)).to be true
    end

    it 'true when visiting the edit password path' do
      expect(helper.hide_login_menu?(edit_user_password_path)).to be true
    end
  end

  describe 'amount_to_refund' do
    let(:application) { build :application, fee: 100, amount_to_pay: 80 }

    context 'application' do
      it 'amount to refund based on amount to pay from application' do
        expect(helper.amount_to_refund(application).to_i).to be(20)
      end
    end

    context 'evidence check' do
      let(:evidence_check) { build :evidence_check, amount_to_pay: 30 }
      let(:application) { build :application, fee: 100, amount_to_pay: 80, evidence_check: evidence_check }

      it 'amount to refund based on amount to pay from evidence check' do
        expect(helper.amount_to_refund(application).to_i).to be(70)
      end
    end
  end

  describe 'amount_to_pay' do
    let(:application) { build :application, fee: 100, amount_to_pay: 80 }

    context 'application' do
      it { expect(helper.amount_to_pay(application).to_i).to be(80) }
    end

    context 'evidence check' do
      let(:evidence_check) { build :evidence_check, amount_to_pay: 30 }
      let(:application) { build :application, fee: 100, amount_to_pay: 80, evidence_check: evidence_check }

      it { expect(helper.amount_to_pay(application).to_i).to be(30) }
    end
  end

  describe 'amount_value' do

    context 'is empty' do
      let(:amount) { nil }
      it { expect(helper.amount_value(amount)).to be_nil }
    end

    context 'has a decimal point' do
      let(:amount) { 100.5 }

      it { expect(helper.amount_value(amount)).to eq(100) }
    end

    context 'is 0' do
      let(:amount) { 0.0 }

      it { expect(helper.amount_value(amount)).to be_nil }
    end
  end
end
