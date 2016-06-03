# coding: utf-8
require 'rails_helper'

RSpec.feature 'Out of time refunds are correctly handled', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let!(:detail)         { create(:complete_detail, :out_of_time_refund) }
  let!(:application)    { create(:application_full_remission, detail: detail, office: office) }

  before do
    dwp_api_response 'No'
    login_as user
    visit application_benefits_path(application)
    choose 'application_benefits_true'
    click_button 'Next'
  end

  scenario 'they should be on the benefit override page' do
    expect(page.current_path).to eql(application_benefit_override_paper_evidence_path(application))
  end

  scenario 'they should be shown the correct warning' do
    expect(page).to have_content('Because this refund was paid more then three months ago')
  end
end
