require 'rails_helper'

RSpec.describe BenefitCheckers::MockApiClient, type: :service do
  subject(:client) { described_class.new }
  let(:params) {
    {
      id: '12345678',
      ni_number: ni_number_for_test,
      surname: 'Jones',
      birth_date: '19800101',
      entitlement_check_date: Time.zone.today.strftime('%Y%m%d')
    }
  }

  describe '#check' do
    context 'return valid No answer' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_no.last }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('No')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Yes answer' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_yes.first }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Yes answer for another NI number' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_yes.last }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Undetermined answer' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_undetermined.first }

      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Undetermined')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Technical fault answer' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_technical_fault.first }

      it 'raise an error' do
        expect { client.check(params) }.to raise_error(Exceptions::TechnicalFaultDwpCheck)
      end
    end

    context 'raise BadRequest error' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_dwp_error.first }
      it 'returns a successful response structure' do
        expect { client.check(params) }.to raise_error(BenefitCheckers::BadRequestError)
      end
    end

    context 'raise BadRequestErrno::ECONNREFUSED error' do
      let(:ni_number_for_test) { Settings.dwp_mock.ni_number_connection_refused.first }
      it 'returns a successful response structure' do
        expect { client.check(params) }.to raise_error(Errno::ECONNREFUSED)
      end
    end
  end
end
