require 'rails_helper'

RSpec.feature 'List deleted applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:who_deleted) { create :user, name: 'Bob' }
  let(:when_deleted) { Time.zone.parse('2015-10-01 10:10:01') }
  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) do
    create :application_full_remission, :deleted_state,
      office: user.office, deleted_at: when_deleted, deleted_by: who_deleted
  end
  let!(:application2) { create :application_part_remission, :deleted_state, office: user.office }
  let!(:application3) { create :application_part_remission, :processed_state, office: user.office }

  scenario 'User lists all deleted applications' do
    visit '/'

    expect(page).to have_content('Deleted applications')

    within '.completed-applications' do
      click_link 'Deleted applications'
    end

    expect(page.current_path).to eql('/deleted_applications')

    within 'table.deleted-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application2.applicant.full_name)
    end
  end

  scenario 'User displays detail of one deleted application' do
    visit '/deleted_applications'

    click_link application1.applicant.full_name

    expect(page.current_path).to eql("/deleted_applications/#{application1.id}")

    expect(page).to have_content('Deleted application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
    expect(page).to have_content('Date deleted1 October 2015')
    expect(page).to have_content('Deleted byBob')
    expect(page).to have_content("Deleted reason#{application1.deleted_reason}")
  end
end
