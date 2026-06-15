require 'rails_helper'

RSpec.feature 'Waiting for part payment sorting' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  let!(:older_zz) do
    create(:application, :waiting_for_part_payment_state,
           office: office,
           completed_at: Time.zone.yesterday.midday - 3.hours,
           detail: create(:detail, form_name: 'ZZ', fee: 500, case_number: 'CN900'))
  end
  let!(:newer_aa) do
    create(:application, :waiting_for_part_payment_state,
           office: office,
           completed_at: Time.zone.yesterday.midday + 3.hours,
           detail: create(:detail, form_name: 'AA', fee: 100, case_number: 'CN100'))
  end

  before do
    create(:part_payment, application: older_zz)
    create(:part_payment, application: newer_aa)
    login_as user
  end

  def listed_references
    page.all('.waiting-for-part_payment tbody tr td:nth-child(2)').map(&:text)
  end

  scenario 'default view sorts by newest processed first' do
    visit part_payments_path

    expect(listed_references).to eq([newer_aa.reference, older_zz.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first.'
  end

  scenario 'choosing a secondary sort orders within the processed date' do
    visit part_payments_path
    select 'Form name', from: 'Then by'
    click_button 'Apply'

    expect(listed_references).to eq([newer_aa.reference, older_zz.reference])
    expect(page).to have_text 'Sorted by Date processed, newest first, then by Form name (ascending).'

    within('.waiting-for-part_payment thead') { click_link 'Form name' }
    expect(listed_references).to eq([older_zz.reference, newer_aa.reference])
  end

  scenario 'reset returns to the default sorting' do
    visit part_payments_path
    choose 'Oldest first'
    click_button 'Apply'
    expect(page).to have_text 'Sorted by Date processed, oldest first.'

    click_link 'Reset sorting'
    expect(page).to have_text 'Sorted by Date processed, newest first.'
  end
end
