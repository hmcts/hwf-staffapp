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

      context 'invalid date' do

        it "discretion denied" do
          visit '/'
          click_button 'Start now'
          expect(page).to have_content "Personal details"
          complete_page_as 'personal_information', application, true

          expect(page).to have_content "Application details"
          complete_page_as 'application_details', application, false
          check "This is a refund case"
          fill_in "application_date_fee_paid", with: 4.months.ago.to_s
          click_button 'Next'
          expect(page).to have_content("This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application")

          within(:xpath, './/fieldset[@class="discretion_applied"]') do
            choose 'No'
          end
          click_button 'Next'

          expect(page).to have_content "Check details"
          expect(page).to have_content "Delivery Manager discretion appliedNo"

          click_button 'Complete processing'
          expect(page).to have_content 'Not eligible for help with fees'
          expect(page).to have_content 'Delivery Manager Discretion✗ Failed'
          expect(page).not_to have_content 'Savings and investments✓ Passed'
        end

        it "discretion granted" do
          visit '/'
          click_button 'Start now'
          expect(page).to have_content "Personal details"
          complete_page_as 'personal_information', application, true

          expect(page).to have_content "Application details"
          complete_page_as 'application_details', application, false
          check "This is a refund case"
          fill_in "application_date_fee_paid", with: 4.months.ago.to_s
          click_button 'Next'
          expect(page).to have_content("This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application")

          within(:xpath, './/fieldset[@class="discretion_applied"]') do
            choose 'Yes'
          end
          click_button 'Next'

          expect(page).to have_content("Enter Delivery Manager name")
          expect(page).to have_content("Enter Discretionary reason")

          within(:xpath, './/fieldset[@class="discretion_applied"]') do
            fill_in 'Discretion manager name', with: 'Dan'
            fill_in 'Discretion reason', with: 'Looks legit'
          end
          click_button 'Next'

          choose 'Less than £3,000'
          fill_in 'application_amount', with: 0
          click_button 'Next'

          expect(page).to have_content "Does the applicant receive benefits?"
          choose 'Yes'
          click_button 'Next'
          expect(page).not_to have_content('Fees paid more than 3 months ago can’t be checked with the DWP.')

          expect(page).to have_content('Has the applicant provided the correct paper evidence of benefits received, which is dated within 3 months of the fee being paid?')
          choose('Yes, the applicant has provided paper evidence')
          click_button 'Next'

          expect(page).to have_content "Check details"

          expect(page).to have_content "Delivery Manager discretion appliedYes"
          expect(page).to have_content "Applicant provided paper evidenceYes"
          expect(page).not_to have_content "Benefits letter checkedNo"

          click_button 'Complete processing'

          expect(page).to have_content 'Benefits✓ Passed'
          expect(page).to have_content 'Eligible for help with fees'
          expect(page).to have_content 'Delivery Manager Discretion✓ Passed'
          expect(page).to have_content 'Savings and investments✓ Passed'
        end
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

      it "discretion granted" do
        visit '/'
        click_button 'Start now'
        expect(page).to have_content "Personal details"
        complete_page_as 'personal_information', application, true

        expect(page).to have_content "Application details"
        complete_page_as 'application_details', application, false
        check "This is a refund case"
        fill_in "application_date_fee_paid", with: 4.months.ago.to_s
        click_button 'Next'
        expect(page).to have_content("This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application")

        within(:xpath, './/fieldset[@class="discretion_applied"]') do
          choose 'Yes'
        end
        click_button 'Next'

        expect(page).to have_content("Enter Delivery Manager name")
        expect(page).to have_content("Enter Discretionary reason")

        within(:xpath, './/fieldset[@class="discretion_applied"]') do
          fill_in 'Discretion manager name', with: 'Dan'
          fill_in 'Discretion reason', with: 'Looks legit'
        end
        click_button 'Next'

        choose 'Less than £3,000'
        fill_in 'application_amount', with: 0
        click_button 'Next'

        expect(page).to have_content "Does the applicant receive benefits?"
        choose 'Yes'
        click_button 'Next'
        expect(page).not_to have_content('Fees paid more than 3 months ago can’t be checked with the DWP.')

        expect(page).to have_content('Has the applicant provided the correct paper evidence of benefits received, which is dated within 3 months of the fee being paid?')
        choose('No')
        click_button 'Next'

        expect(page).to have_content "Check details"

        expect(page).to have_content "Delivery Manager discretion appliedYes"

        click_button 'Complete processing'

        expect(page).to have_content 'Benefits✗ Failed'
        expect(page).to have_content '✗   Not eligible for help with fees'
        expect(page).to have_content 'Delivery Manager Discretion✓ Passed'
      end
    end
  end
end
