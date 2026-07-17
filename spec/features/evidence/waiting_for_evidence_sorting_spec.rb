require 'rails_helper'

RSpec.feature 'Waiting for evidence sorting' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  let!(:older_zz) do
    create(:application, :waiting_for_evidence_state,
           office: office,
           completed_at: Time.zone.yesterday.midday - 3.hours,
           detail: create(:detail, form_name: 'ZZ', fee: 500, case_number: 'CN900'))
  end
  let!(:newer_aa) do
    create(:application, :waiting_for_evidence_state,
           office: office,
           completed_at: Time.zone.yesterday.midday + 3.hours,
           detail: create(:detail, form_name: 'AA', fee: 100, case_number: 'CN100'))
  end
  let!(:oldest_mm) do
    create(:application, :waiting_for_evidence_state,
           office: office,
           completed_at: 3.days.ago,
           detail: create(:detail, form_name: 'MM', fee: 300, case_number: 'CN500'))
  end

  before { login_as user }

  def listed_references
    page.all('.waiting-for-evidence tbody tr td:nth-child(2)').map(&:text)
  end

  scenario 'default view sorts by newest processed first' do
    visit evidence_checks_path

    expect(listed_references).to eq([newer_aa.reference, older_zz.reference, oldest_mm.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first.'
  end

  scenario 'switching the primary sort to oldest first' do
    visit evidence_checks_path
    choose 'Oldest first'
    click_button 'Apply'

    expect(listed_references).to eq([oldest_mm.reference, older_zz.reference, newer_aa.reference])
    expect(page).to have_text 'Sorted by Date processed, oldest first.'
  end

  scenario 'choosing a secondary sort orders within the processed date' do
    visit evidence_checks_path
    select 'Form name', from: 'Then by'
    click_button 'Apply'

    expect(listed_references).to eq([newer_aa.reference, older_zz.reference, oldest_mm.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first, then by Form name (ascending).'
  end

  scenario 'clicking the active secondary header toggles its direction' do
    visit evidence_checks_path
    select 'Form name', from: 'Then by'
    click_button 'Apply'
    within('.waiting-for-evidence thead') { click_link 'Form name' }

    expect(listed_references).to eq([older_zz.reference, newer_aa.reference, oldest_mm.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first, then by Form name (descending).'
  end

  scenario 'clicking an inactive sortable header selects it as the secondary sort' do
    visit evidence_checks_path
    within('.waiting-for-evidence thead') { click_link 'Case number' }

    expect(page).to have_text 'Sorted by Date processed, newest first, then by Case number (ascending).'
    expect(listed_references).to eq([newer_aa.reference, older_zz.reference, oldest_mm.reference])
  end

  scenario 'combining oldest first with a secondary sort' do
    visit evidence_checks_path
    choose 'Oldest first'
    select 'Court fee', from: 'Then by'
    click_button 'Apply'

    expect(listed_references).to eq([oldest_mm.reference, newer_aa.reference, older_zz.reference])
    expect(page).to have_text 'Sorted by Date processed, oldest first, then by Court fee (ascending).'
  end

  scenario 'reset returns to the default sorting' do
    visit evidence_checks_path
    choose 'Oldest first'
    click_button 'Apply'
    click_link 'Reset sorting'

    expect(listed_references).to eq([newer_aa.reference, older_zz.reference, oldest_mm.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first.'
  end

  scenario 'sorting persists across pagination' do
    visit evidence_checks_path(per_page: 2, filter_applications: { order_choice: 'Ascending' })

    expect(listed_references).to eq([oldest_mm.reference, older_zz.reference])

    click_link '2'
    expect(listed_references).to eq([newer_aa.reference])
    expect(page).to have_text 'Sorted by Date processed, oldest first.'
  end
end
