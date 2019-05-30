require 'rails_helper'

RSpec.describe BenefitCheck, type: :model do
  let(:user)  { create :user }
  let(:check) { build :benefit_check }

  it 'pass factory build' do
    expect(check).to be_valid
  end

  context 'scopes' do
    let(:application) { build :application }
    let(:digital) { create(:office, name: 'Digital') }
    let(:bristol) { create(:office, name: 'Bristol') }

    describe 'non_digital' do
      let(:digital_application) { create(:application, office: digital, user: user) }
      let(:bristol_application) { create(:application, office: bristol, user: user) }

      before do
        digital_application.benefit_checks.new
        bristol_application.benefit_checks.new
        digital_application.save
        bristol_application.save
      end

      describe 'excludes dwp checks by digital staff' do
        it { expect(described_class.count).to eq 2 }
        it { expect(described_class.non_digital.count).to eq 1 }
      end
    end

    describe 'checks_by_day' do
      let(:created_out_of_scope) { Time.zone.today.- 8.days }
      let(:created_in_scope) { Time.zone.today.-5.days }
      before do
        create(:benefit_check, created_at: created_out_of_scope.to_s, application_id: application.id)
        create(:benefit_check, created_at: created_in_scope.to_s, application_id: application.id)
      end
      it 'finds only checks for the past week' do
        expect(described_class.checks_by_day.count).to eq 1
      end
    end

    describe 'by_office' do
      let(:digital_application) { create(:application, office: digital, user: user) }
      let(:bristol_application) { create(:application, office: bristol, user: user) }

      before do
        digital_application.benefit_checks.new
        bristol_application.benefit_checks.new
        digital_application.save
        bristol_application.save
      end

      describe 'lists all the checks from the same office' do
        it { expect(described_class.by_office(bristol.id).count).to eq 1 }
        it { expect(described_class.by_office(digital.id).count).to eq 1 }
      end
    end

    describe 'by_office_grouped_by_type' do
      let(:digital_application) { create(:application, office: digital, user: user) }
      before do
        digital_application.benefit_checks.new dwp_result: 'No'
        digital_application.benefit_checks.new dwp_result: 'Deceased'
        digital_application.save
      end

      describe 'lists checks by length of dwp_result' do
        it { expect(described_class.by_office_grouped_by_type(digital.id).count.keys[0]).to eql('No') }
        it { expect(described_class.by_office_grouped_by_type(digital.id).count.keys[1]).to eql('Deceased') }
      end
    end
  end

  describe '#outcome' do
    subject { check.outcome }

    context 'when dwp_result is Yes' do
      let(:check) { build :benefit_check, :yes_result }

      it { is_expected.to eql 'full' }
    end

    context 'when dwp_result is No' do
      let(:check) { build :benefit_check, :no_result }

      it { is_expected.to eql 'none' }
    end

    context 'when dwp_result is nil or anything else' do
      let(:check) { build :benefit_check }

      it { is_expected.to eql 'none' }
    end
  end
end
