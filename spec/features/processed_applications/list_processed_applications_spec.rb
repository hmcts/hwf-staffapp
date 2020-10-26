require 'rails_helper'

RSpec.feature 'List processed applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let!(:application1) { create :application_full_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-10') }
  let!(:application2) { create :application_part_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-03') }
  let!(:application4) { create :application_full_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-07') }
  let!(:application5) { create :application_part_remission, :processed_state, office: user.office, decision_date: Time.zone.parse('2016-01-06') }
  before do
    create :application_part_remission
    create :part_payment, outcome: 'part', correct: true, application: application5
    login_as(user)
  end

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

    click_link 'Next'

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application5.applicant.full_name)
      expect(page).to have_content(application2.applicant.full_name)
    end

    click_link 'Previous'

    within 'table.processed-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application4.applicant.full_name)
    end
    expect(page).to have_link('Top of page')
  end

  scenario 'User displays detail of one processed application' do
    visit '/processed_applications'

    click_link application1.reference

    expect(page.current_path).to eql("/processed_applications/#{application1.id}")

    expect(page).to have_content('Processed application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
  end

  scenario 'User displays detail of one processed part-payment application' do
    visit '/processed_applications'
    click_link 'Next'
    click_link application5.reference

    expect(page).to have_content('Processed application')
    expect(page).to have_content('The applicant has paid £100 towards the fee')
  end

  context 'with evidence check' do
    before { create :evidence_check_full_outcome, application: application5 }

    scenario 'contains income from evidence check and from application' do
      visit '/processed_applications'
      click_link 'Next'
      click_link application5.reference

      expect(page).to have_content('Processed application')
      expect(page).to have_text('Total monthly income£2,000')
      expect(page).to have_text('Total monthly income from Evidence£100')
    end
  end

  context 'without evidence check' do
    scenario 'contains income from evidence check and from application' do
      visit '/processed_applications'
      click_link 'Next'
      click_link application5.reference

      expect(page).to have_content('Processed application')
      expect(page).to have_text('Total monthly income£2,000')
      expect(page).not_to have_text('Total monthly income from Evidence')
    end
  end
end
