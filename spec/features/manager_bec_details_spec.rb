require 'rails_helper'

RSpec.feature 'Show BEC in the jurisdiction radio buttons', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdictions) { create_list :jurisdiction, 3 }
  let(:office) { create(:office, jurisdictions: jurisdictions) }
  let(:manager) { create(:manager, jurisdiction_id: jurisdictions[1].id, office: office) }

  scenario 'view the office details' do
    login_as(manager)
    visit office_path(manager.office)

    expect(page).to have_text 'Office details'

    click_link 'Change details'

    manager.office.business_entities.each do |be|
      expect(page).to have_text("#{be.jurisdiction.display_full} (#{be.code})")
    end
  end
end
