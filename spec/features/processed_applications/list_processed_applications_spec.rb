require 'rails_helper'

RSpec.feature 'List processed applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) { create :application_full_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-10') }
  let!(:application2) { create :application_part_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-03') }
  let!(:application3) { create :application_part_remission }
  let!(:application4) { create :application_full_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-07') }
  let!(:application5) { create :application_part_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-06') }

  scenario 'User lists all processed applications with pagination and in correct order' do
    visit '/'

    expect(page).to have_content('Processed applications')

    within '.completed-applications' do
      click_link 'Processed applications'
    end

    expect(page.current_path).to eql('/processed_applications')

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application4.applicant.full_name)
    end

    click_link 'Next page'

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application5.applicant.full_name)
      expect(page).to have_content(application2.applicant.full_name)
    end

    click_link 'Previous page'

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application4.applicant.full_name)
    end
  end

  scenario 'User displays detail of one processed application' do
    visit '/processed_applications'

    click_link application1.reference

    expect(page.current_path).to eql("/processed_applications/#{application1.id}")

    expect(page).to have_content('Processed application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
  end
end
