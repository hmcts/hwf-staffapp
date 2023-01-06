require 'rails_helper'

RSpec.describe Query::LastDwpFailedApplications do
  subject(:query) { described_class.new(user) }
  let(:user) { create(:user, office: office1) }
  let(:office1) { create(:office) }
  let(:office2) { create(:office) }

  describe '#find' do
    subject { query.find }

    let(:application1) { create(:application, :benefit_type, user: user, reference: 'ABC1', office: office1) }
    let(:application2) { create(:application, :benefit_type, user: user, reference: 'ABC2', office: office1) }
    let(:application3) { create(:application_full_remission, :benefit_type, user: user, reference: 'ABC3', office: office1) }
    let(:application4) { create(:application_full_remission, user: user, reference: 'ABC4', office: office1) }
    let(:application5) { create(:application, :benefit_type, user: user, reference: 'ABC5', office: office1) }
    let(:application6) { create(:application, :benefit_type, user: user, reference: 'ABC6', office: office1) }
    let(:application7) { create(:application, :benefit_type, :processed_state, user: user, reference: 'ABC7', office: office1) }

    before do
      Timecop.freeze(3.months.ago + 1.day) do
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application5)
      end

      Timecop.freeze(3.months.ago) do
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application6)
      end

      Timecop.freeze(2.hours.ago) do
        create(:benefit_check, :yes_result, applicationable: application1, updated_at: 2.hours.ago)
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application2)
      end

      Timecop.freeze(1.hour.ago) do
        # duplicating the call so we can test for duplication in final query
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application1)
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application1)
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application2)
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application2)
      end

      create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application1)
      create(:benefit_check, :yes_result, applicationable: application2)
      create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application3)
      application4
      create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application7)
    end

    it "contains applications with failed dwp benefit checks only" do
      is_expected.to match_array([application5, application1, application2])
    end

    context 'same office' do
      let(:user2) { create(:user, office: office1) }
      subject(:query) { described_class.new(user2) }

      it 'loads applications for same office' do
        expect(query.find).to match_array([application5, application1, application2])
      end
    end

    context 'difference office' do
      let(:user2) { create(:user, office: office2) }
      subject(:query) { described_class.new(user2) }

      it 'loads applications for different office' do
        expect(query.find).to match_array([])
      end

      context 'admin user' do
        let(:user3) { create(:user, office: office2, role: 'admin') }
        subject(:query) { described_class.new(user3) }
        it { expect(query.find.size).to eq(4) }

        it 'loads applications for same office' do
          expect(query.find).to match_array([application5, application1, application2, application3])
        end
      end
    end
  end
end
