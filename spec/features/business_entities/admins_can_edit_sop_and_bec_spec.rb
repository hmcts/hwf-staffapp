require 'rails_helper'

RSpec.feature 'Business entity management around SOP and BEC switchover ', type: :feature do
  let(:admin) { create :admin_user, office: office }

  let(:office) { create :office }
  let(:business_entity) { office.business_entities.first }

  before do
    login_as admin
    visit "offices/#{office.id}/business_entities/#{business_entity.id}/edit"
  end

  context 'after the switchover date' do

    scenario 'user cannot edit the be_code' do
      expect(page).not_to have_xpath("//input[@name='business_entity[be_code]' and @value='#{business_entity.be_code}' and @disabled]")
    end

    scenario 'user can edit the sop_code' do
      expect(page).to have_xpath("//input[@name='business_entity[sop_code]' and @value='#{business_entity.sop_code}']")
    end

  end
end
