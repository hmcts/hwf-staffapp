require 'rails_helper'

RSpec.feature 'Office management', type: :feature do

  pending "this was a feature that existed previously but doesn't any more" do
    # NOTE: NOT deleting it as it's in the backlog and not removing it
    # here, just for visibility
    #
    # Also, this test is 'noisy' in this pending state and I want it
    # like that for now until it's fixed.

    include Warden::Test::Helpers
    Warden.test_mode!

    let(:user)          { create :user }
    let(:admin_user)    { create :admin_user }
    let(:office_name)   { 'new court' }
    let(:entity_code)   { 'N0111' }

    context 'Admin user' do
      scenario 'creates a new office' do

        login_as(admin_user, scope: :user)
        visit new_office_path

        fill_in 'office_name', with: office_name
        fill_in 'office_entity_code', with: entity_code
        click_button 'Create Office'

        expect(page).to have_xpath('//label', text: 'Name')
        expect(page).to have_xpath('/html/body/div[4]/div/div[1]/div[1]/div[2]', text: office_name)

        expect(page).to have_xpath('//label', text: 'Entity code')
        expect(page).to have_xpath('/html/body/div[4]/div/div[1]/div[1]/div[4]', text: entity_code)
      end
    end
  end
end
