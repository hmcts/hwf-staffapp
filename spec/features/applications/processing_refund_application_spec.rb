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

  before do
    login_as user
    dwp_api_response 'Yes'
  end

  it "should not fail based on wrong date" do
    visit '/'
    fill_in :online_search_reference, with: online_application_1.reference
    click_button 'Look up'
    choose jurisdiction.name
    click_button 'Next'
    click_button 'Complete processing'
    # save_and_open_page
    expect(page).to have_content 'Savings and investments✓ Passed'
    expect(page).to have_content 'Benefits✓ Passed'
    expect(page).to have_content 'Eligible for help with fees'
  end
end