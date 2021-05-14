# coding: utf-8

require 'rails_helper'

describe HmrcApiService do
  subject(:service) { described_class.new(application) }
  let(:application) { create :application_part_remission, applicant: applicant }
  let(:applicant) {
    create :applicant,
           date_of_birth: DateTime.new(1968, 2, 28),
           ni_number: 'AB123456C',
           first_name: 'Jimmy',
           last_name: 'Conners'
  }
  let(:hmrc_api) { instance_double(HwfHmrcApi::Connection) }

  describe "HMRC API gem" do
    before do
      ENV['HMRC_SECRET'] = 'secret'
      ENV['HMRC_TTP_SECRET'] = 'base32secret3232'
      ENV['HMRC_CLIENT_ID'] = '12345'

    end
    context 'ENV variables' do
      it "without token" do
        allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
        allow(hmrc_api).to receive(:match_user)
        service
        expect(HwfHmrcApi).to have_received(:new).with({ hmrc_secret: "secret", totp_secret: "base32secret3232", client_id: "12345" })
      end

      # it "with token" do
      #   allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
      #   allow(hmrc_api).to receive(:match_user)
      #   service
      #   expect(HwfHmrcApi).to have_received(:new).with({:hmrc_secret=>"secret", :totp_secret=>"base32secret3232", :client_id=>"12345"})
      # end
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
        allow(hmrc_api).to receive(:match_user)
        service
        expect(hmrc_api).to have_received(:match_user).with(applicant_info)
      end
    end
  end
end
