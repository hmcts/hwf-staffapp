require 'rails_helper'

describe HmrcMonitor do
  subject(:service) { described_class.new }

  it { is_expected.to be_a described_class }

  describe '#state' do
    subject { service.state }

    let(:evidence_check) { create(:evidence_check, application: create(:application)) }

    def create_checks(count, error_response)
      create_list(:hmrc_check, count, evidence_check: evidence_check, error_response: error_response)
    end

    context 'when there are no hmrc checks' do
      it { is_expected.to eql 'online' }
    end

    context 'when all recent checks succeeded' do
      before { create_checks(10, nil) }

      it { is_expected.to eql 'online' }
    end

    context 'when fewer than 25% of the last 10 checks are service failures' do
      before do
        create_checks(8, nil)
        create_checks(2, 'API: SERVER_ERROR - Service unavailable')
      end

      it { is_expected.to eql 'online' }
    end

    context 'when 25% or more of the last 10 checks are service failures' do
      before do
        create_checks(7, nil)
        create_checks(3, 'API: SERVER_ERROR - Service unavailable')
      end

      it { is_expected.to eql 'warning' }
    end

    context 'when 50% or more of the last 10 checks are service failures' do
      before do
        create_checks(5, nil)
        create_checks(5, 'API: INTERNAL_SERVER_ERROR - Something went wrong.')
      end

      it { is_expected.to eql 'offline' }
    end

    context 'when the failures are applicant data problems, not service failures' do
      before do
        create_checks(10, 'API: MATCHING_FAILED - There is no match for the information provided')
      end

      it { is_expected.to eql 'online' }
    end

    context 'when the failure is the local tax credit entitlement check' do
      before do
        create_checks(10, I18n.t('hmrc_summary.entitlement_date'))
      end

      it { is_expected.to eql 'online' }
    end

    context 'when only the last 10 checks count' do
      before do
        create_checks(10, 'API: SERVER_ERROR - Service unavailable')
        create_checks(10, nil)
      end

      it { is_expected.to eql 'online' }
    end

    context 'with each known service failure message' do
      let(:service_failures) do
        ['API: INTERNAL_SERVER_ERROR - Something went wrong.',
         'API: invalid_client - invalid client id or secret',
         'API: INVALID_SCOPE - Can not access the required resource. Ensure this token has all the required scopes.',
         "API: SERVER_ERROR - The 'individuals/matching' API is currently unavailable",
         'API: FORBIDDEN - This endpoint is not available',
         'API: server_error - An unexpected error occurred',
         'API: SERVER_ERROR - Service unavailable',
         'API: MESSAGE_THROTTLED_OUT - The request for the API is throttled as you have exceeded your quota.',
         'API: RESOURCE_FORBIDDEN - ',
         'Net::ReadTimeout - Timeout error']
      end

      it 'reports offline for every one of them' do
        service_failures.each do |message|
          checks = create_checks(10, message)
          expect(described_class.new.state).to eql('offline'), "expected offline for #{message.inspect}"
          checks.each(&:destroy)
        end
      end
    end
  end
end
