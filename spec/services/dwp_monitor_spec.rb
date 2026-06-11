require 'rails_helper'

describe DwpMonitor do
  subject(:service) { described_class.new }

  it { is_expected.to be_a described_class }

  describe 'methods' do
    describe '.state' do
      subject { service.state }

      context 'when more than 50% of the last dwp_results are "400 Bad Request"' do
        before { build_dwp_checks_with_bad_requests }

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 50% of the last "server unavailable - The benefits checker is not available at the moment..."' do
        before { build_dwp_checks_with_server_unavailable }

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 50% of the last dwp_results are validation "Bad Request"' do
        before do
          create_list(:benefit_check, 10, dwp_result: 'BadRequest', error_message: 'entitlement_check_date is invalid')
        end

        it { is_expected.to eql 'online' }
      end

      context 'when more than 25% of the last dwp_results are "400 Bad Request"' do
        before { build_dwp_checks_with_bad_requests(6, 4) }

        it { is_expected.to eql 'warning' }
      end

      context 'checks for all error messages' do
        before { build_dwp_checks_with_all_errors }

        it { is_expected.to eql 'warning' }
      end

      context 'when less than 25% of the last dwp_results are "400 Bad Request"' do
        before { build_dwp_checks_with_bad_requests(8, 2) }

        it { is_expected.to eql 'online' }
      end

      context 'when more than 50% are "Technical fault"' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 6, dwp_result: 'Technical fault',
                                         error_message: I18n.t('error_messages.benefit_checker.unavailable'))
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 50% are "Rate limited"' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 6, dwp_result: 'Rate limited',
                                         error_message: I18n.t('error_messages.benefit_checker.rate_limited'))
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 50% are "Unspecified error"' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 6, dwp_result: 'Unspecified error', error_message: 'Some unexpected error')
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 50% are "Undetermined"' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 6, dwp_result: 'Undetermined',
                                         error_message: I18n.t('error_messages.benefit_checker.undetermined'))
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when there is a mix of different error types' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 2, dwp_result: 'Technical fault',
                                         error_message: I18n.t('error_messages.benefit_checker.unavailable'))
          create_list(:benefit_check, 2, dwp_result: 'Rate limited',
                                         error_message: I18n.t('error_messages.benefit_checker.rate_limited'))
          create_list(:benefit_check, 2, dwp_result: 'Unspecified error', error_message: 'Something broke')
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when there are no benefit checks' do
        it { is_expected.to eql 'online' }
      end

      context 'when all results are successful Yes/No' do
        before do
          create_list(:benefit_check, 5, :yes_result)
          create_list(:benefit_check, 5, :no_result)
        end

        it { is_expected.to eql 'online' }
      end

      context 'when a previously unknown dwp_result appears' do
        before do
          create_list(:benefit_check, 4, :yes_result)
          create_list(:benefit_check, 6, dwp_result: 'NewErrorType', error_message: 'something new from DWP')
        end

        it { is_expected.to eql 'offline' }
      end
    end
  end
end
