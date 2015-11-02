require 'rails_helper'

RSpec.feature 'Evidence check page displayed instead of confirmation', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  let(:application) { create :application_full_remission, reference: Random.srand }

  scenario 'User continues from the summary page when building the application and is redirected to evidence check' do
    create_list :application_full_remission, 9

    visit application_build_path(application_id: application.id, id: 'income_result')

    click_button 'Next'

    expect(page).to have_content 'Evidence of income needs to be checked for this application'

    click_link 'Complete processing'

    expect(evidence_check_rendered?).to be true
  end

  scenario 'User tries to display confirmation page directly and is redirected to evidence check' do
    create :evidence_check, application: application

    visit application_confirmation_path(application.id)

    expect(evidence_check_rendered?).to be true
  end

  def evidence_check_rendered?
    (%r{\/evidence_checks\/#{application.evidence_check.id}} =~ page.current_url) != nil
  end
end
