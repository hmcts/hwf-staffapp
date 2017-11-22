# coding: utf-8

require 'rails_helper'

RSpec.feature 'Processing refund application with valid date received date', type: :feature do

  let(:jurisdiction) { create :jurisdiction }
  let(:office) { create :office, jurisdictions: [jurisdiction] }
  let(:user) { create :user, office: office }

  let(:online_application_1) do
    create(:online_application, :completed, :with_reference,
      married: false,
      children: 3,
      benefits: true,
      fee: 1550,
      form_name: 'D11',
      income_min_threshold_exceeded: false,
      refund: true,
      date_fee_paid: 4.months.ago,
      date_received: 2.months.ago,
      jurisdiction: jurisdiction)
  end

  let(:online_application_2) do
    create(:online_application, :completed, :with_reference,
      married: false,
      children: 3,
      benefits: true,
      fee: 1550,
      form_name: 'D11',
      income_min_threshold_exceeded: false,
      refund: true,
      date_fee_paid: 5.months.ago,
      date_received: 3.months.ago,
      jurisdiction: jurisdiction)
  end

  before do
    login_as user
    dwp_api_response 'Yes'
  end

  it "do not fail when valid date" do
    visit '/'
    fill_in :online_search_reference, with: online_application_1.reference
    click_button 'Look up'
    expect(page).to have_content "Application details"
    choose jurisdiction.name
    click_button 'Next'
    expect(page).to have_content "Check details"
    click_button 'Complete processing'

    expect(page).to have_content 'Savings and investments✓ Passed'
    expect(page).to have_content 'Benefits✓ Passed'
    expect(page).to have_content 'Eligible for help with fees'
  end

  it "ingnore online application when invalid date" do
    visit '/'
    fill_in :online_search_reference, with: online_application_2.reference
    click_button 'Look up'
    expect(page).to have_content "Application details"
    choose jurisdiction.name
    click_button 'Next'
    expect(page).to have_content "Check details"
    click_button 'Complete processing'

    expect(page).to have_content 'Savings and investments✓ Passed'
    expect(page).to have_content 'Benefits✓ Passed'
    expect(page).to have_content 'Eligible for help with fees'
  end
end
