def fill_personal_details(ni_number = 'SN123456C')
  expect(page).to have_text 'Personal details'
  fill_in 'Title', with: 'Mr.'
  fill_in 'First and middle names', with: 'Johny'
  fill_in 'Last name', with: 'Mnemonick'
  fill_in 'Date of birth', with: '01/01/2000'
  fill_in 'National Insurance number', with: ni_number
  choose 'Single'
  click_button 'Next'
end

def fill_application_details(fee = 1000)
  expect(page).to have_text 'Application details'
  fill_in 'Fee', with: fee
  choose Jurisdiction.first.display_full.to_s
  fill_in 'Date application received', with: Date.yesterday.to_s
  click_button 'Next'
end

def fill_application_refund_details(fee = 1000)
  expect(page).to have_text 'Application details'
  fill_in 'Fee', with: fee
  choose Jurisdiction.first.display_full.to_s
  fill_application_dates
end

def fill_application_dates
  fill_in 'Date application received', with: Date.yesterday.to_s
  check 'This is a refund case'

  fill_in 'Date fee paid', with: 2.days.ago.to_date.to_s
  click_button 'Next'
end

def fill_application_emergency_details(fee = 1000)
  expect(page).to have_text 'Application details'
  fill_in 'Fee', with: fee
  choose Jurisdiction.first.display_full.to_s
  fill_in 'Date application received', with: Date.yesterday.to_s
  check 'This is an emergency case'
  fill_in 'Reason for emergency', with: "I'm in hurry"
  click_button 'Next'
end

def fill_saving_and_investment
  expect(page).to have_text 'Savings and investments'
  choose 'Less than £3,000'
  click_button 'Next'
end

def fill_benefits(benefits)
  expect(page).to have_text 'Benefits'
  choose benefits ? 'Yes' : 'No'

  click_button 'Next'
end

def fill_benefit_evidence(benefits_options)
  expect(page).to have_text 'Has the applicant provided paper evidence?'
  if benefits_options[:paper_provided]
    choose 'Yes, the applicant has provided paper evidence'
    if benefits_options[:paper_correct]
      choose 'Yes, the evidence is correct'
    else
      choose 'No'
    end
  else
    choose 'benefit_override_evidence_false'
  end

  click_button 'Next'
end

def fill_income(supporting_children, income = 1000, children = 2)
  expect(page).to have_text 'Income'
  if supporting_children
    choose 'Yes'
    fill_in 'Number of children', with: children
  else
    choose 'No'
  end
  fill_in 'Total monthly income', with: income

  click_button 'Next'
end

def has_evidence_check?
  evidene_check.present?
end

def has_evidence_check_flagged?
  ev_check = evidene_check
  ev_check && ev_check.check_type == 'flag'
end

def evidene_check
  reference_number = find(:xpath, './/span[@class="reference-number"]').text
  application = Application.where(reference: reference_number).last
  application.try(:evidence_check)
end

def create_flag_check(ni_number)
  EvidenceCheckFlag.create(ni_number: ni_number, active: true, count: 1)
end
