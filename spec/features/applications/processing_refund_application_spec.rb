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

  context 'Online refund application' do
    it "do not fail when valid date" do
      visit '/'
      fill_in :online_search_reference, with: online_application_1.reference
      click_button 'Look up'
      expect(page).to have_content "Application details"
      choose jurisdiction.name
      date_received = find(:xpath, './/input[@id="online_application_date_received"]').value
      expect(date_received).to eq(online_application_1.date_received.to_s)

      click_button 'Next'
      expect(page).to have_content "Check details"
      click_button 'Complete processing'

      expect(page).to have_content 'Savings and investments✓ Passed'
      expect(page).to have_content 'Benefits✓ Passed'
      expect(page).to have_content 'Eligible for help with fees'
    end

    it "ignore date_received date because it was already validated" do
      visit '/'
      fill_in :online_search_reference, with: online_application_2.reference
      click_button 'Look up'
      expect(page).to have_content "Application details"
      choose jurisdiction.name
      date_received = find(:xpath, './/input[@id="online_application_date_received"]').value
      expect(date_received).to eq(online_application_2.date_received.to_s)

      click_button 'Next'
      expect(page).to have_content "Check details"
      click_button 'Complete processing'

      expect(page).to have_content 'Savings and investments✓ Passed'
      expect(page).to have_content 'Benefits✓ Passed'
      expect(page).to have_content 'Eligible for help with fees'
    end

  end

  context 'Postal refund application' do
    let(:applicant) { build :applicant_with_all_details }
    let(:application) { build :application, applicant: applicant }

    context 'with benefits' do
      it "valid date" do
        visit '/'
        click_button 'Start now'
        expect(page).to have_content "Personal details"
        complete_page_as 'personal_information', application, true

        expect(page).to have_content "Application details"
        complete_page_as 'application_details', application, false
        check "This is a refund case"
        fill_in "application_date_fee_paid", with: 10.days.ago.to_s
        click_button 'Next'

        choose 'Less than £3,000'
        fill_in 'application_amount', with: 0
        click_button 'Next'

        expect(page).to have_content "Does the applicant receive benefits?"
        choose 'Yes'
        click_button 'Next'

        expect(page).to have_content "Check details"
        click_button 'Complete processing'

        expect(page).to have_content 'Savings and investments✓ Passed'
        expect(page).to have_content 'Benefits✓ Passed'
        expect(page).to have_content 'Eligible for help with fees'
      end

      it "paper evidence check if invalid date" do
        visit '/'
        click_button 'Start now'
        expect(page).to have_content "Personal details"
        complete_page_as 'personal_information', application, true

        expect(page).to have_content "Application details"
        complete_page_as 'application_details', application, false
        check "This is a refund case"
        fill_in "application_date_fee_paid", with: 4.months.ago.to_s
        click_button 'Next'

        choose 'Less than £3,000'
        fill_in 'application_amount', with: 0
        click_button 'Next'

        expect(page).to have_content "Does the applicant receive benefits?"
        choose 'Yes'
        click_button 'Next'
        expect(page).to have_content "Fees paid more than 3 months ago can’t be checked with the DWP. The applicant must provide paper evidence to show they were receiving eligible benefits on the date they paid"
        choose "benefit_override_evidence_true"
        choose "benefit_override_correct_true"
        click_button 'Next'

        click_button 'Complete processing'

        expect(page).to have_content 'Savings and investments✓ Passed'
        expect(page).to have_content 'Benefits✓ Passed'
        expect(page).to have_content 'Eligible for help with fees'
      end
    end

    context 'without benefits' do
      it "valid date" do
        visit '/'
        click_button 'Start now'
        expect(page).to have_content "Personal details"
        complete_page_as 'personal_information', application, true

        expect(page).to have_content "Application details"
        complete_page_as 'application_details', application, false
        check "This is a refund case"
        fill_in "application_date_fee_paid", with: 10.days.ago.to_s
        click_button 'Next'

        choose 'Less than £3,000'
        fill_in 'application_amount', with: 0
        click_button 'Next'

        expect(page).to have_content "Does the applicant receive benefits?"
        choose 'No'
        click_button 'Next'

        expect(page).to have_content "In question 10, does the applicant financially support any children?"
        choose 'No'
        fill_in 'application_income', with: 1000
        click_button 'Next'

        expect(page).to have_content "Check details"
        click_button 'Complete processing'

        expect(page).to have_content 'Savings and investments✓ Passed'
        expect(page).to have_content 'Eligible for help with fees'
      end

      it "paper evidence check if invalid date" do
        visit '/'
        click_button 'Start now'
        expect(page).to have_content "Personal details"
        complete_page_as 'personal_information', application, true

        expect(page).to have_content "Application details"
        complete_page_as 'application_details', application, false
        check "This is a refund case"
        fill_in "application_date_fee_paid", with: 4.months.ago.to_s
        click_button 'Next'

        choose 'Less than £3,000'
        fill_in 'application_amount', with: 0
        click_button 'Next'

        expect(page).to have_content "Does the applicant receive benefits?"
        choose 'No'
        click_button 'Next'

        expect(page).to have_content "Fees paid more than 3 months ago can’t be checked with the DWP. The applicant must provide paper evidence to show they were receiving eligible benefits on the date they paid"
        choose "benefit_override_evidence_true"
        choose "benefit_override_correct_true"
        click_button 'Next'
        binding.pry

        click_button 'Complete processing'

        expect(page).to have_content 'Savings and investments✓ Passed'
        expect(page).to have_content 'Benefits✓ Passed'
        expect(page).to have_content 'Eligible for help with fees'
      end
    end
  end
end
