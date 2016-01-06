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

    manager.office.jurisdictions.each do |jurisdiction|
      jurisdiction.business_entities.pluck(:code) do |code|
        expect(page).to have_text("#{jurisdiction.name} (#{code})")
      end
    end
  end
end
