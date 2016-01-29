require 'rails_helper'

RSpec.feature 'When showing offices, managers', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdictions) { create_list :jurisdiction, 3 }
  let(:office) { create(:office, jurisdictions: jurisdictions) }
  let(:manager) { create(:manager, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:office2) { create :office }

  scenario 'can view their own office' do
    login_as(manager)
    visit office_path(manager.office)
    expect(page).to have_text 'Office details'
  end

  scenario 'cannot view other offices' do
    login_as(manager)
    visit office_path(office2)
    expect(page).to have_text 'You don’t have permission to do this'
  end
end
