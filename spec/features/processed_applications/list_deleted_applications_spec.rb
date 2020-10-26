require 'rails_helper'

RSpec.feature 'List deleted applications', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:who_deleted) { create :user, name: 'Bob' }
  let(:when_deleted) { Time.zone.parse('2016-05-19 10:10:01') }
  let(:user) { create :user }

  before do
    login_as(user)
  end

  let!(:application1) do
    create :application_full_remission, :deleted_state,
           office: user.office, deleted_at: when_deleted, deleted_by: who_deleted
  end
  let!(:application2) { create :application_part_remission, :deleted_state, office: user.office, deleted_at: Time.zone.parse('2016-04-01') }
  let(:application3) { create :application_part_remission, :processed_state, office: user.office }
  let!(:application4) { create :application_part_remission, :deleted_state, office: user.office, deleted_at: Time.zone.parse('2016-04-02') }
  let!(:application5) { create :application_part_remission, :deleted_state, office: user.office, deleted_at: Time.zone.parse('2016-03-11') }

  scenario 'User lists all deleted applications with pagination' do
    visit '/'

    expect(page).to have_content('Deleted applications')

    within '.completed-applications' do
      click_link 'Deleted applications'
    end

    expect(page.current_path).to eql('/deleted_applications')

    within 'table.deleted-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application4.applicant.full_name)
    end

    click_link 'Next'

    within 'table.deleted-applications tbody' do
      expect(page).to have_content(application2.applicant.full_name)
      expect(page).to have_content(application5.applicant.full_name)
    end

    click_link 'Previous'

    within 'table.deleted-applications tbody' do
      expect(page).to have_content(application1.applicant.full_name)
      expect(page).to have_content(application4.applicant.full_name)
    end
  end

  scenario 'User displays detail of one deleted application' do
    visit '/deleted_applications'

    click_link application1.reference

    expect(page.current_path).to eql("/deleted_applications/#{application1.id}")

    expect(page).to have_content('Deleted application')
    expect(page).to have_content("Full name#{application1.applicant.full_name}")
    expect(page).to have_content("Application deleted19 May 2016BobReason for deletion: \"#{application1.deleted_reason}\"")
  end
end
