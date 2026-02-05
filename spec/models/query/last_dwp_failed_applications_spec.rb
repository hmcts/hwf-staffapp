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
    let(:application3) { create(:online_application, :benefits, user: user, reference: 'ABC3') }
    let(:application4) { create(:application_full_remission, user: user, reference: 'ABC4', office: office1) }
    let(:application5) { create(:application, :benefit_type, user: user, reference: 'ABC5', office: office1) }
    let(:application6) { create(:application, :benefit_type, user: user, reference: 'ABC6', office: office1) }
    let(:application7) { create(:application, :benefit_type, :processed_state, user: user, reference: 'ABC7', office: office1) }

    before do
      travel_to(3.months.ago + 1.day) do
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application5, user: user)
      end

      travel_to(3.months.ago) do
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application6, user: user)
      end

      travel_to(2.hours.ago) do
        create(:benefit_check, :yes_result, applicationable: application1, updated_at: 2.hours.ago, user: user)
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application2, user: user)
      end

      travel_to(1.hour.ago) do
        # duplicating the call so we can test for duplication in final query
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application1, user: user)
        create(:benefit_check, dwp_result: 'Unspecified error', error_message: 'Server broke connection', applicationable: application1, user: user)
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application2, user: user)
        create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application2, user: user)
      end

      create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application1, user: user)
      create(:benefit_check, :yes_result, applicationable: application2, user: user)
      create(:benefit_check, dwp_result: 'Server unavailable', error_message: 'The benefits checker is not available at the moment.', applicationable: application3, user: user)
      application4
      create(:benefit_check, dwp_result: 'BadRequest', error_message: 'LSCBC959: Service unavailable.', applicationable: application7, user: user)
    end

    it "contains applications with failed dwp benefit checks only" do
      is_expected.to match_array([application5, application1, application2, application3])
    end

    context 'online application converted to paper application' do
      let(:online_application) { create(:online_application, :benefits, user: user, reference: 'ONLINE1') }

      before do
        create(:benefit_check, dwp_result: 'Server unavailable',
                               error_message: 'The benefits checker is not available at the moment.',
                               applicationable: online_application, user: user)
      end

      context 'when linked application is still in created state' do
        before do
          create(:application, :benefit_type, user: user, reference: 'ONLINE1', office: office1, online_application: online_application)
        end

        it 'includes the online application in the list' do
          is_expected.to include(online_application)
        end
      end

      context 'when linked application has been processed' do
        before do
          create(:application, :benefit_type, :processed_state, user: user, reference: 'ONLINE1', office: office1, online_application: online_application)
        end

        it 'excludes the online application from the list' do
          is_expected.not_to include(online_application)
        end
      end
    end

    context 'same office' do
      let(:user2) { create(:user, office: office1) }
      subject(:query) { described_class.new(user2) }

      it 'loads applications for same office' do
        expect(query.find).to match_array([application5, application1, application2, application3])
      end
    end

    context 'difference office' do
      let(:user2) { create(:user, office: office2) }
      subject(:query) { described_class.new(user2) }

      it 'loads applications for different office' do
        expect(query.find).to be_empty
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
