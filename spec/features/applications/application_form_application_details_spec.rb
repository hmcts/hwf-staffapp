require 'rails_helper'

RSpec.feature 'Completing the application details page of an application form', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions)      { create_list :jurisdiction, 3 }
  let!(:office)             { create(:office, jurisdictions: jurisdictions) }
  let!(:user)               { create(:user, jurisdiction_id: nil, office: office) }
  let!(:user_jurisdiction)  { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:persona)             { single_under_61 }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                  "confirmation_ref": "T1426267181940",
                  "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
    stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
      to_return(status: 200, body: json, headers: {})
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user with default jurisdiction', js: true do
    before do
      login_as user_jurisdiction
      visit applications_new_path
      complete_page_as 'personal_information', persona, true
    end

    it 'renders the page' do
      expect(page).to have_xpath('//h2', text: 'Application details')
    end

    context 'submitting the form empty' do
      before { click_button 'Next' }

      scenario 'renders error' do
        expect(page).to have_xpath('//label[@class="error"]', count: '2')
      end
    end

    context 'before expanding optional fields' do
      it 'are hidden' do
        expect(page).to_not have_xpath('//input[@id="application_deceased_name"]')
        expect(page).to_not have_xpath('//input[@id="application_date_fee_paid"]')
      end

      context 'expanding probate' do
        before { check 'application_probate' }

        it 'shows the probate section' do
          expect(page).to have_xpath('//input[@id="application_deceased_name"]')
        end

        context 'submitting empty' do
          before { click_button 'Next' }

          scenario 'renders errors' do
            expect(page).to have_xpath('//label[@class="error"]', count: '4')
          end
        end
      end

      context 'expanding refund' do
        before { check 'application_refund' }

        it 'shows the refund section' do
          expect(page).to have_xpath('//input[@id="application_date_fee_paid"]')
        end

        context 'submitting empty' do
          before { click_button 'Next' }

          scenario 'renders errors' do
            expect(page).to have_xpath('//label[@class="error"]', count: '3')
          end
        end
      end
    end

    context 'completing the mandatory fields' do
      before { complete_page_as 'application_details', persona, true }

      context 'and submitting the form' do
        scenario 'renders the next page' do
          expect(page).to have_xpath('//h2', text: 'Savings and investments')
        end
      end
    end
  end

  context 'as a signed in user without default jurisdiction ', js: true do
    before do
      login_as user
      visit applications_new_path
      complete_page_as 'personal_information', persona, true
    end

    it 'renders the page' do
      expect(page).to have_xpath('//h2', text: 'Application details')
    end

    context 'submitting the form empty' do
      before { click_button 'Next' }

      scenario 'renders error' do
        expect(page).to have_xpath('//label[@class="error"]', count: '3')
      end
    end
  end
end
