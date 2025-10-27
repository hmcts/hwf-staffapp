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
      let(:ni_number_for_test) { 'SN789654B' }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('No')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Yes answer' do
      let(:ni_number_for_test) { 'SN789654A' }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Yes answer for another NI number' do
      let(:ni_number_for_test) { 'JR054008D' }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end

    context 'return valid Undetermined answer' do
      let(:ni_number_for_test) { 'SN789654C' }
      it 'returns a successful response structure' do
        result = client.check(params)
        expect(result[:benefit_checker_status]).to eq('Undetermined')
        expect(result[:confirmation_ref]).to include('MOCK-')
      end
    end
  end
end
