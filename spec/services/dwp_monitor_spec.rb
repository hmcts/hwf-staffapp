require 'rails_helper'

describe DwpMonitor do
  subject(:service) { described_class.new }

  it { is_expected.to be_a described_class }

  describe 'methods' do
    describe '.state' do
      subject { service.state }

      context 'when more than 50% of the last dwp_results are "400 Bad Request"' do
        before do
          create_list :benefit_check, 5, :yes_result
          create_list :benefit_check, 5, dwp_result: 'Unspecified error', error_message: '400 Bad Request'
        end

        it { is_expected.to eql 'offline' }
      end

      context 'when more than 25% of the last dwp_results are "400 Bad Request"' do
        before do
          create_list :benefit_check, 6, :yes_result
          create_list :benefit_check, 4, dwp_result: 'Unspecified error', error_message: '400 Bad Request'
        end

        it { is_expected.to eql 'warning' }
      end

      context 'when less than 25% of the last dwp_results are "400 Bad Request"' do
        before do
          create_list :benefit_check, 8, :yes_result
          create_list :benefit_check, 2, dwp_result: 'Unspecified error', error_message: '400 Bad Request'
        end

        it { is_expected.to eql 'online' }
      end
    end
  end
end
