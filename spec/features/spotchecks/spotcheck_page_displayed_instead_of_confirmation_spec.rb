require 'rails_helper'

RSpec.feature 'Spot check page displayed instead of confirmation', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as user
  end

  let(:application) { create :application_full_remission }
  let!(:spotcheck) { create :spotcheck, application: application }

  scenario 'User continues from the summary page when building the application' do
    visit application_build_path(application_id: application.id, id: 'income_result')

    click_button 'Next'
    click_button 'Continue'

    expect(spotcheck_rendered?).to be true
  end

  scenario 'User tries to display confirmation page directly' do
    visit application_build_path(application_id: application.id, id: 'confirmation')

    expect(spotcheck_rendered?).to be true
  end

  def spotcheck_rendered?
    (%r{\/spotchecks\/#{spotcheck.id}} =~ page.current_url) != nil
  end
end
