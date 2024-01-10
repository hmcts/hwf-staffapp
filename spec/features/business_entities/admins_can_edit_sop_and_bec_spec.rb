require 'rails_helper'

RSpec.feature 'Business entity management around SOP and BEC switchover' do
  let(:admin) { create(:admin_user, office: office) }

  let(:office) { create(:office) }
  let(:business_entity) { create(:business_entity, office: office) }

  before do
    login_as admin
    visit "offices/#{office.id}/business_entities/#{business_entity.id}/edit"
  end

  context 'after the switchover date' do

    scenario 'user cannot edit the be_code' do
      expect(page).to have_no_xpath("//input[@name='business_entity[be_code]' and @value='#{business_entity.be_code}' and @disabled]")
    end

    scenario 'user can edit the sop_code' do
      expect(page).to have_xpath("//input[@name='business_entity[sop_code]' and @value='#{business_entity.sop_code}']")
    end

  end
end
