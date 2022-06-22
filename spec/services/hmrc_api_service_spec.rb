# coding: utf-8

require 'rails_helper'

describe HmrcApiService do
  subject(:service) { described_class.new(evidence_check.application, processing_user.id) }
  let(:application) { create :application_part_remission, applicant: applicant }
  let(:processing_user) { create :user }
  let(:evidence_check) { create :evidence_check, application: application }
  let(:applicant) {
    create :applicant,
           date_of_birth: DateTime.new(1968, 2, 28),
           ni_number: 'AB123456C',
           first_name: 'Jimmy',
           last_name: 'Conners'
  }
  let(:hmrc_api) { instance_double(HwfHmrcApi::Connection) }
  let(:hmrc_api_authentication) { instance_double(HwfHmrcApi::Authentication, access_token: 1, expires_in: 1) }
  let(:hmrc_call) { instance_double(HmrcCall, id: correlation_id) }
  let(:correlation_id) { '692f8ec9-0bd3-4f5d-ac54-3e21c94abec6' }

  describe "HMRC API gem" do
    before do
      ENV['HMRC_SECRET'] = 'secret'
      ENV['HMRC_TTP_SECRET'] = 'base32secret3232'
      ENV['HMRC_CLIENT_ID'] = '12345'
      allow(hmrc_api).to receive(:authentication).and_return hmrc_api_authentication
    end

    context 'ENV variables' do
      it "without token" do
        allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
        allow(hmrc_api).to receive(:match_user)
        service.match_user
        expect(HwfHmrcApi).to have_received(:new).with({ hmrc_secret: "secret", totp_secret: "base32secret3232", client_id: "12345" })
      end

      context 'stored token' do
        before {
          allow(HmrcToken).to receive(:last).and_return hmrc_token
          allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
          allow(hmrc_api).to receive(:match_user)
        }
        let(:expires_in) { Time.zone.parse('01-02-2021 10:50') }
        let(:hmrc_token) { HmrcToken.create(access_token: '123456', expires_in: expires_in) }

        it "expired" do
          allow(hmrc_token).to receive(:expired?).and_return true
          service.match_user
          expect(HwfHmrcApi).to have_received(:new).with({ hmrc_secret: "secret", totp_secret: "base32secret3232", client_id: "12345" })
        end

        it "valid" do
          allow(hmrc_token).to receive(:expired?).and_return false
          service.match_user
          expect(HwfHmrcApi).to have_received(:new).with({
                                                           hmrc_secret: "secret",
                                                           totp_secret: "base32secret3232",
                                                           client_id: "12345",
                                                           access_token: '123456',
                                                           expires_in: expires_in
                                                         })
        end

        context 'update token in DB' do
          context 'token did not changed' do
            before do
              allow(hmrc_token).to receive(:expired?).and_return false
              allow(hmrc_api_authentication).to receive(:access_token).and_return '111333'
              allow(hmrc_api_authentication).to receive(:expires_in).and_return Time.zone.parse('01-03-2021 10:50')
              service.match_user
            end

            it { expect(HmrcToken.last.access_token).to eq '111333' }
            it { expect(HmrcToken.last.expires_in).to eq Time.zone.parse('01-03-2021 10:50') }
          end

          context 'token changed' do
            before do
              allow(hmrc_token).to receive(:expired?).and_return true
              allow(hmrc_api_authentication).to receive(:access_token).and_return '123456'
              allow(hmrc_api_authentication).to receive(:expires_in).and_return Time.zone.parse('01-03-2021 10:50')
              service.match_user
            end

            it { expect(HmrcToken.last.access_token).to eq '123456' }
            it { expect(HmrcToken.last.expires_in).to eq expires_in }
          end

        end
      end
    end

    context 'match_user' do
      let(:applicant_info) {
        {
          dob: "1968-02-28",
          nino: 'AB123456C',
          first_name: "Jimmy",
          last_name: "Conners"
        }
      }

      it "applicant params" do
        allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
        allow(HmrcCall).to receive(:create).and_return hmrc_call
        allow(hmrc_api).to receive(:match_user)
        service.match_user
        expect(hmrc_api).to have_received(:match_user).with(applicant_info, correlation_id)
      end

      context 'hmrc_call' do
        before do
          allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
          allow(hmrc_api).to receive(:match_user)
          service.match_user
        end

        it { expect(HmrcCall.last.endpoint_name).to eq('match_user') }
        it { expect(HmrcCall.last.call_params).to eq(applicant_info) }
      end
    end

    context "Get data for" do
      before {
        allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
        allow(hmrc_api).to receive(:match_user)
        service.match_user
      }

      context "income" do
        before do
          allow(hmrc_api).to receive(:paye).and_return('income' => [{ paymentDate: "2019-01-01" }])
          allow(hmrc_api).to receive(:child_tax_credits).and_return([{ "awards" => ['child test'] }])
          allow(hmrc_api).to receive(:working_tax_credits).and_return([{ "awards" => ['work test'] }])
          allow(HmrcCall).to receive(:create).and_return hmrc_call
        end

        it 'paye' do
          service.income('2020-02-28', '2020-03-30')
          expect(hmrc_api).to have_received(:paye).with('2020-02-28', '2020-03-30', correlation_id)
        end

        context 'tax_credit' do
          it "child_tax_credit" do
            service.tax_credit('2020-02-28', '2020-03-30')
            expect(hmrc_api).to have_received(:child_tax_credits).with('2020-02-28', '2020-03-30', correlation_id)
          end

          it "work_tax_credit" do
            service.tax_credit('2020-02-28', '2020-03-30')
            expect(hmrc_api).to have_received(:working_tax_credits).with('2020-02-28', '2020-03-30', correlation_id)
          end
        end
      end

      it "address" do
        allow(HmrcCall).to receive(:create).and_return hmrc_call
        allow(hmrc_api).to receive(:addresses).and_return('address' => [{ endDate: "2019-01-01" }])
        service.address('2020-02-28', '2020-03-30')
        expect(hmrc_api).to have_received(:addresses).with('2020-02-28', '2020-03-30', correlation_id)
      end

      it "employment" do
        allow(HmrcCall).to receive(:create).and_return hmrc_call
        allow(hmrc_api).to receive(:employments).and_return('employment' => [{ startDate: "2019-01-02" }])
        service.employment('2020-02-28', '2020-03-30')
        expect(hmrc_api).to have_received(:employments).with('2020-02-28', '2020-03-30', correlation_id)
      end

      context 'no results' do
        it 'income' do
          allow(hmrc_api).to receive(:paye).and_return('income' => [])
          expect { service.income('2020-02-28', '2020-03-30') }.to raise_error(an_instance_of(HwfHmrcApiError))
        end

        it 'addresses' do
          allow(hmrc_api).to receive(:addresses).and_return('address' => [])
          expect { service.address('2020-02-28', '2020-03-30') }.to raise_error(an_instance_of(HwfHmrcApiError))
        end

        it 'employments' do
          allow(hmrc_api).to receive(:employments).and_return('employment' => [])
          expect { service.employment('2020-02-28', '2020-03-30') }.to raise_error(an_instance_of(HwfHmrcApiError))
        end
      end
    end

    context "Store data for" do
      before {
        allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
        allow(hmrc_api).to receive(:match_user)
        service.match_user
      }

      context 'metadata' do
        it 'ni_number' do
          expect(service.hmrc_check.ni_number).to eql('AB123456C')
        end

        it 'date_of_birth' do
          expect(service.hmrc_check.date_of_birth).to eql('1968-02-28')
        end

        it 'user_id from initializer' do
          expect(service.hmrc_check.user_id).to eql(processing_user.id)
        end
      end

      context 'income' do
        before do
          allow(hmrc_api).to receive(:paye).and_return('income' => [{ paymentDate: "2019-01-01" }])
          allow(hmrc_api).to receive(:child_tax_credits).and_return([{ "awards" => ['child test'] }])
          allow(hmrc_api).to receive(:working_tax_credits).and_return([{ "awards" => ['work test'] }])
          allow(HmrcCall).to receive(:create).and_return hmrc_call
          service.income('2020-02-28', '2020-03-30')
        end

        it 'query' do
          expect(service.hmrc_check.income[0][:paymentDate]).to eq "2019-01-01"
        end

        it 'request_params from' do
          expect(service.hmrc_check.request_params[:date_range][:from]).to eql('2020-02-28')
        end

        it 'request_params to' do
          expect(service.hmrc_check.request_params[:date_range][:to]).to eql('2020-03-30')
        end

        context 'tax_credit' do
          it "child" do
            expect(service.hmrc_check.child_tax_credit[0]).to eq 'child test'
          end

          it "work" do
            expect(service.hmrc_check.work_tax_credit[0]).to eq 'work test'
          end

          it "hmrc_call" do
            expect(HmrcCall).to have_received(:create).exactly(3).times
          end
        end
      end

      it "address" do
        allow(hmrc_api).to receive(:addresses).and_return('address' => [{ endDate: "2019-01-01" }])
        service.address('2020-02-28', '2020-03-30')
        expect(service.hmrc_check.address[0][:endDate]).to eq "2019-01-01"
      end

      it "employment" do
        allow(hmrc_api).to receive(:employments).and_return('employment' => [{ startDate: "2019-01-02" }])
        service.employment('2020-02-28', '2020-03-30')
        expect(service.hmrc_check.employment[0][:startDate]).to eq "2019-01-02"
      end
    end
  end
end
