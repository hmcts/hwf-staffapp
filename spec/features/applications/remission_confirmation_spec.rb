require 'rails_helper'

RSpec.feature 'Confirmation page for remission', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:application) { create(:application_part_remission) }

  context 'as a signed in user', js: true do
    before do
      WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
      Capybara.current_driver = :webkit
      json = '{"original_client_ref": "unique", "benefit_checker_status": "No",
                  "confirmation_ref": "T1426267181940",
                  "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
      stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
      {
        birth_date: application.date_of_birth.strftime('%Y%m%d'),
        entitlement_check_date: application.date_received.strftime('%Y%m%d'),
        id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
        ni_number: application.ni_number,
        surname: application.last_name.upcase
      }).to_return(status: 200, body: json, headers: {})
      login_as user
    end

    after { Capybara.use_default_driver }

    context 'who has part remission' do
      let(:part_remission_copy) do
        ['Write to the applicant with details of how much they have to pay',
         'Complete the remission register with the application details',
         'Write the reference number on the top right corner of the paper form',
         'Copy the reference number into the case management system ']
      end

      context 'after user continues to confirmation page' do
        before do
          visit application_build_path(application_id: application.id, id: 'confirmation')
        end

        scenario 'the part remission copy is show' do
          part_remission_copy.each {|line| expect(page).to have_text line }
        end
      end
    end

    context 'who has full remission' do
      let(:application) { create(:application_full_remission) }
      let(:full_remission_copy) do
        ['Complete the remission register with the application details',
         'Write the reference number form the remission register on the top right corner of the paper form',
         'Write to the applicant and send back all the documents']
      end

      context 'after user continues to confirmation page' do
        before do
          visit application_build_path(application_id: application.id, id: 'confirmation')
        end

        scenario 'the full remission copy is shown' do
          expect(application.application_outcome).to eq 'full'
          full_remission_copy.each {|line| expect(page).to have_text line }
        end
      end
    end
  end
end
