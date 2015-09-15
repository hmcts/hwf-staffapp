# coding: utf-8
require 'rails_helper'

describe BenefitCheckService do

  context 'called with invalid object' do
    it 'fails' do
      expect {
        described_class.new(nil)
      }.to raise_error
    end
  end

  context 'called with valid params' do
    context 'passing a benefit_check object' do
      let(:user) { create(:user) }
      let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME') }

      before(:each) do
        json = '{"original_client_ref": "' + check.our_api_token + '", "benefit_checker_status": "Yes",
               "confirmation_ref": "T1426267181940",
               "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
          {
            id: check.our_api_token,
            birth_date: '19800101',
            entitlement_check_date: "#{Time.zone.yesterday.strftime('%Y%m%d')}",
            ni_number: 'AB123456A',
            surname: 'LAST_NAME'
          }).to_return(status: 200, body: json, headers: {})
        described_class.new(check)
      end

      it 'does not raise error' do
        expect {
          described_class.new(check)
        }.not_to raise_error
      end

      it 'sets the dwp_result' do
        expect(check.dwp_result).to eql('Yes')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to eql(true)
      end

      it 'sets the dwp_api_token' do
        expect(check.dwp_api_token).to eql('T1426267181940')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to eql(true)
      end

      it 'sets the dwp_api_token' do
        expect(check.dwp_api_token).to eql('T1426267181940')
      end

      context 'simulating a 500 error' do
        let(:user) { create(:user) }
        let(:check) { create(:benefit_check, user_id: user.id, date_of_birth: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME') }

        before(:each) do
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
            to_return(status: 500, body: '', headers: {})
          described_class.new(check)
        end

        it 'returns the error in message' do
          expect(check.error_message).to eql('500 Internal Server Error')
        end

        it 'returns fail' do
          expect(check.benefits_valid).to eql(false)
        end
      end
    end
    context 'passing a dwp_check' do
      let(:user) { create(:user) }
      let(:check) { create(:dwp_check, created_by_id: user.id, dob: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME') }

      before(:each) do
        json = '{"original_client_ref": "' + check.our_api_token + '", "benefit_checker_status": "Yes",
             "confirmation_ref": "T1426267181940",
             "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
        {
          id: check.our_api_token,
          birth_date: '19800101',
          entitlement_check_date: "#{Time.zone.yesterday.strftime('%Y%m%d')}",
          ni_number: 'AB123456A',
          surname: 'LAST_NAME'
        }).to_return(status: 200, body: json, headers: {})
        described_class.new(check)
      end

      it 'does not raise error' do
        expect {
          described_class.new(check)
        }.not_to raise_error
      end

      it 'sets the dwp_result' do
        expect(check.dwp_result).to eql('Yes')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to eql(true)
      end

      it 'sets the dwp_id' do
        expect(check.dwp_id).to eql('T1426267181940')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to eql(true)
      end

      it 'sets the dwp_id' do
        expect(check.dwp_id).to eql('T1426267181940')
      end

      it 'returns success=true' do
        expect(JSON.parse(described_class.new(check).result)['success']).to eql(true)
      end

      context 'returns a result object' do
        let(:parsed) { JSON.parse(described_class.new(check).result) }
        it 'as json' do
          expect(parsed.count).to eql(3)
        end
        describe 'containing a field named' do
          it 'success' do
            expect(parsed).to include('success')
          end
          it 'dwp_check' do
            expect(parsed).to include('dwp_check')
          end
          it 'message' do
            expect(parsed).to include('message')
          end
        end
      end

      context 'returns a result object' do
        let(:parsed) { JSON.parse(described_class.new(check).result) }
        it 'as json' do
          expect(parsed.count).to eql(3)
        end
        describe 'containing a field named' do
          it 'success' do
            expect(parsed).to include('success')
          end
          it 'dwp_check' do
            expect(parsed).to include('dwp_check')
          end
          it 'message' do
            expect(parsed).to include('message')
          end
        end
      end

      context 'when api_proxy returns undetermined' do
        before(:each) do
          json = '{"original_client_ref": "' + check.our_api_token + '", "benefit_checker_status": "Undetermined",
             "confirmation_ref": "T1426267181940",
             "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
          {
            id: check.our_api_token,
            birth_date: '19800101',
            entitlement_check_date: "#{Time.zone.yesterday.strftime('%Y%m%d')}",
            ni_number: 'AB123456A',
            surname: 'LAST_NAME'
          }).to_return(status: 200, body: json, headers: {})
        end

        let(:parsed) { JSON.parse(described_class.new(check).result) }

        it 'returns the error message' do
          expect(parsed['message']).to eql('The details you’ve entered are incorrect, check and try again')
        end

        it 'returns fail' do
          expect(parsed['success']).to eql(false)
        end
      end

      context 'simulating a 500 error' do
        let(:user) { create(:user) }
        let(:check) { create(:dwp_check, created_by_id: user.id, dob: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME') }

        before(:each) do
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
            to_return(status: 500, body: '', headers: {})
        end

        let(:parsed) { JSON.parse(described_class.new(check).result) }

        it 'returns the error in message' do
          expect(parsed['message']).to eql('500 Internal Server Error')
        end

        it 'returns fail' do
          expect(parsed['success']).to eql(false)
        end
      end
    end

  end

  context 'called with invalid params' do
    context 'when api_proxy returns undetermined' do
      let(:invalid_check) { create(:invalid_benefit_check) }
      before(:each) do
        json = '{"original_client_ref": "an-api-token", "benefit_checker_status": "Undetermined",
               "confirmation_ref": "T1426267181940",
               "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
        {
          id: 'build-a-token',
          birth_date: '19800101',
          entitlement_check_date: "#{Time.zone.yesterday.strftime('%Y%m%d')}",
          ni_number: 'AB123456A',
          surname: ''
        }).to_return(status: 200, body: json, headers: {})
        described_class.new(invalid_check)
      end

      it 'returns the error message' do
        expect(invalid_check.error_message).to eql('The details you’ve entered are incorrect, check and try again')
      end

      it 'returns fail' do
        expect(invalid_check.benefits_valid).to eql(false)
      end
    end
  end
end
