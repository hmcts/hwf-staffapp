require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application) { build :application }

  before { WebMock.disable_net_connect!(allow: 'codeclimate.com') }

  it 'has a valid factory build' do
    expect(application).to be_valid
  end

  describe 'Benefits result section' do
    before { application.status = 'benefits_result' }

    describe 'Methods' do
      it 'responds to can_check_benefit?' do
        expect(application).to respond_to :can_check_benefits?
      end

      it 'responds to last_benefit_check'do
        expect(application).to respond_to :last_benefit_check
      end
    end

    describe 'last_benefit_check' do
      context 'when no benefit checks have been made' do
        before { application.benefit_checks.delete_all }

        it 'returns nil' do
          expect(application.last_benefit_check).to be_nil
        end
      end

      context 'when at more than one check has been made' do
        before do
          application.benefit_checks.new
          application.save
        end

        it 'returns a benefit check' do
          expect(application.last_benefit_check).to be_a BenefitCheck
        end
      end
    end

    describe 'can_check_benefit?' do
      context 'when all fields are complete' do
        before do
          application.date_of_birth = Time.zone.today - 20.years
          application.date_received = Time.zone.today - 1.month
          application.ni_number = 'AB123456A'
          application.last_name = 'Test'
        end

        it 'returns true' do
          expect(application.can_check_benefits?).to eq true
        end
      end

      context 'when fields are incomplete' do
        before { application.date_of_birth = nil }

        it 'returns false' do
          expect(application.can_check_benefits?).to eq false
        end
      end
    end
  end
end
