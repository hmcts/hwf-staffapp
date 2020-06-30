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

      context 'when more than 50% of the last dwp_results are validation "Bad Request"' do
        before do
          create_list :benefit_check, 10, dwp_result: 'BadRequest', error_message: 'entitlement_check_date is invalid'
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
    end
  end
end
