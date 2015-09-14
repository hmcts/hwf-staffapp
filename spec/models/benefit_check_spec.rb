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

    before(:each) do
      described_class.delete_all
      application.status = 'benefits_result'
    end


    describe 'non_digital' do
      let(:digital_application) { create(:application, office: digital, user: user) }
      let(:bristol_application) { create(:application, office: bristol, user: user) }

      before(:each) do
        digital_application.benefit_checks.new
        bristol_application.benefit_checks.new
        digital_application.save
        bristol_application.save
      end

      it 'excludes dwp checks by digital staff' do
        expect(described_class.count).to eql(2)
        expect(described_class.non_digital.count).to eql(1)
      end
    end

    xdescribe 'checks_by_day' do
      let!(:old_check) do
        create(:benefit_check,
               created_at: "#{Time.zone.today.-8.days}",
               application_id: application.id
        )
      end
      let!(:new_check) do
        create(:benefit_check,
               created_at: "#{Time.zone.today.-5.days}",
               application_id: application.id
        )
      end
      it 'finds only checks for the past week' do
        expect(described_class.checks_by_day.count).to eq 1
      end
    end

    xdescribe 'by_office' do
      let!(:office1) { create(:office) }
      let!(:office2) { create(:office) }
      let!(:user) { create(:user, office_id: office1.id) }

      let!(:check) do
        create :dwp_check, created_by_id: user.id, office_id: user.office_id
      end

      let!(:another_user) { create(:user, office_id: office2.id) }

      let!(:another_check) do
        create :dwp_check, created_by_id: another_user.id, office_id: another_user.office_id
      end

      it 'lists all the checks from the same office' do
        expect(described_class.by_office(user.office_id).count).to eq 1
        expect(described_class.by_office(another_user.office_id).count).to eq 1
      end
    end

    xdescribe 'by_office_grouped_by_type' do
      let!(:office) { create(:office) }
      let!(:user) { create(:user, office_id: office.id) }
      let!(:check) do
        create(:dwp_check, dwp_result: 'Deceased', created_by: user, office_id: user.office_id)
      end
      let!(:another_check) do
        create(:dwp_check, dwp_result: 'No', created_by_id: user.id, office_id: user.office_id)
      end

      it 'lists checks by length of dwp_result' do
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[0]).to eql('No')
        expect(described_class.by_office_grouped_by_type(user.office_id).count.keys[1]).to eql('Deceased')
      end
    end
  end
end
