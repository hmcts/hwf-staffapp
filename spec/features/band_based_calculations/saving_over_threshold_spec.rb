require 'rails_helper'

RSpec.feature 'Application stores correct data' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }

  let(:online_application_1) do
    create(:online_application, :completed, :with_reference,
           married: true,
           children: 2,
           fee: nil,
           children_age_band: { "one" => "0", "two" => "2" },
           benefits: false,
           income: 6560,
           income_min_threshold_exceeded: false,
           calculation_scheme: "q4_23")
  end

  before do
    login_as user
  end

  context 'Amount to pay checks' do
    before do
      FeatureSwitching.create(feature_key: :band_calculation, enabled: true)
      allow(FeatureSwitching).to receive(:calculation_scheme).and_return('q4_23')
    end

    scenario 'Saving failed for over 66' do
      start_new_application

      fill_in 'application_day_date_received', with: '01'
      fill_in 'application_month_date_received', with: Time.zone.today.month
      fill_in 'application_year_date_received', with: Time.zone.today.year
      choose 'application_refund_false'
      click_button 'Next'

      fill_personal_details_over_66_post_ucd
      choose 'Single'
      click_button 'Next'

      fill_in 'application_fee', with: 100
      select_jurisdiction
      fill_in 'application_form_name', with: 'ABC123'
      click_button 'Next'

      expect(page).to have_text 'Savings and investments'

      url = current_url
      match = url.match(%r{applications/(\d+)/savings_investments})
      application_id = match[1] if match
      expect(Application.find(application_id).detail.calculation_scheme).to eq('q4_23')

      find(:css, '#application_choice_more', visible: :all, wait: 2).click

      click_button 'Next'
      choose 'application_statement_signed_by_applicant'
      click_button 'Next'

      click_button 'Complete processing'
      expect(page).to have_content('Not eligible for help with fee')
      reference = find(:css, 'strong.reference-number').text
      application = Application.find_by(reference: reference)
      expect(application.outcome).to eq('none')
      expect(application.amount_to_pay).to eq(100)
    end

    scenario 'Saving failed single under 66' do
      start_new_application

      fill_in 'application_day_date_received', with: '01'
      fill_in 'application_month_date_received', with: Time.zone.today.month
      fill_in 'application_year_date_received', with: Time.zone.today.year
      choose 'application_refund_false'
      click_button 'Next'

      fill_personal_details_under_66_post_ucd
      choose 'Single'
      click_button 'Next'

      fill_in 'application_fee', with: 2200
      select_jurisdiction
      fill_in 'application_form_name', with: 'ABC123'
      click_button 'Next'

      expect(page).to have_text 'Savings and investments'
      find(:css, '#application_choice_between', visible: :all, wait: 2).click

      fill_in 'application_amount', with: '6900'
      choose 'application_over_66_false'
      click_button 'Next'

      choose 'application_statement_signed_by_applicant'
      click_button 'Next'

      click_button 'Complete processing'
      expect(page).to have_content('Not eligible for help with fee')
      reference = find(:css, 'strong.reference-number').text
      application = Application.find_by(reference: reference)
      expect(application.outcome).to eq('none')
      expect(application.amount_to_pay).to eq(2200)
    end

    scenario 'Premium failed married children' do
      start_new_application

      fill_in 'application_day_date_received', with: '01'
      fill_in 'application_month_date_received', with: Time.zone.today.month
      fill_in 'application_year_date_received', with: Time.zone.today.year
      choose 'application_refund_false'
      click_button 'Next'

      fill_personal_details_under_66_post_ucd
      choose 'Married or living with someone'

      click_button 'Next'

      fill_in 'application_fee', with: 2200
      select_jurisdiction
      fill_in 'application_form_name', with: 'ABC123'
      click_button 'Next'

      expect(page).to have_text 'Savings and investments'
      expect(page).to have_text 'In question 8, how much do they have in savings and investments?'
      find(:css, '#application_choice_less', visible: :all, wait: 2).click

      click_button 'Next'

      choose 'application_benefits_false'
      click_button 'Next'

      choose 'application_dependents_true'
      fill_in 'application_children_age_band_two', with: '2'
      click_button 'Next'

      find_by_id('application_income_kind_applicant_child_credit', wait: 2).click
      click_button 'Next'

      find_by_id('application_income_kind_partner_child_credit', wait: 2).click
      click_button 'Next'

      fill_in 'application_income', with: 6560
      choose 'application_income_period_last_month'
      click_button 'Next'

      choose 'application_statement_signed_by_applicant'
      click_button 'Next'

      click_button 'Complete processing'
      expect(page).to have_content('Not eligible for help with fee')
      reference = find(:css, 'strong.reference-number').text
      application = Application.find_by(reference: reference)
      expect(application.outcome).to eq('none')
      expect(application.amount_to_pay).to eq(2200)
    end

    scenario 'Onine application - Premium failed married children' do
      online_application_1
      visit home_index_url

      reference = online_application_1.reference
      fill_in 'online_search[reference]', with: reference
      click_button 'Look up'

      fill_in :online_application_fee, with: '2200', wait: true
      choose Jurisdiction.first.display_full.to_s
      fill_in :online_application_day_date_received, with: Date.current.day
      fill_in :online_application_month_date_received, with: Date.current.month
      fill_in :online_application_year_date_received, with: Date.current.year

      click_button 'Next'

      click_button 'Complete processing'
      expect(page).to have_content('Not eligible for help with fee')

      application = Application.find_by(reference: reference)
      expect(application.outcome).to eq('none')
      expect(application.amount_to_pay).to eq(2200)
      expect(application.detail.fee).to eq(2200)
      expect(application.income).to eq(6560)
    end
  end
end
