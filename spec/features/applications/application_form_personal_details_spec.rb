require 'rails_helper'

RSpec.feature 'Starting an application form', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi'])
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user', js: true do
    before do
      login_as user
      visit applications_new_path
    end

    it 'renders the page' do
      expect(page).to have_xpath('//h2', text: 'Personal details')
    end

    context 'submitting the form empty' do
      before { click_button 'Next' }

      scenario 'renders 3 errors' do
        expect(page).to have_xpath('//label[@class="error"]', count: '3')
      end
    end

    Personae.all_personae.each do |persona|
      context "completing the fields as #{persona.persona_name}" do
        before { complete_page_as 'personal_information', persona, false }

        context 'and submitting the form' do
          before { click_button 'Next' }
          scenario 'renders the next page' do
            expect(page).to have_xpath('//h2', text: 'Application details')
          end
        end
      end
    end
  end
end
