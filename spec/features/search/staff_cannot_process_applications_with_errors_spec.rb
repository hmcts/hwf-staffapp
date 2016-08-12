require 'rails_helper'

RSpec.feature 'Staff are prevented from processing online applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :staff }
  let!(:online_application) { create :online_application, :with_reference, :invalid_income }

  before do
    login_as user
  end

  scenario 'when the income data is missing income data' do
    given_user_is_on_the_homepage
    when_they_search_for_an_application_with_missing_data
    they_are_shown_a_warning
  end

  def given_user_is_on_the_homepage
    visit '/'
  end

  def when_they_search_for_an_application_with_missing_data
    fill_in :online_search_reference, with: online_application.reference
    click_button 'Look up'
  end

  def they_are_shown_a_warning
    expect(page).to have_content(I18n.t('activemodel.errors.models.forms/search.attributes.reference.income_error'))
  end
end
