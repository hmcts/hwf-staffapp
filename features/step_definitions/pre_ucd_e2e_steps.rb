Given('UCD changes are inactive') do
  disable_feature_switch('band_calculation')
end

When('I successfully submit my required application details pre UCD') do
  application_details_page.submit_fee_600_pre_ucd
end

When('I sucessfully submit my savings and investments pre UCD') do
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
end

When('I submit the application signed by myself') do
  expect(declaration_page.content).to have_header
  declaration_page.sign_by_applicant
end

Then('I should see check details page pre UCD') do
  expect(summary_page.content).to have_header
  expect(summary_page.content.summary_section[2].list_row[0].text).to have_content 'Less than £3,000 Yes Change Less than £3,000'

  expect(summary_page.content).to have_personal_details_header
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_content 'Full name John Christopher Smith Change Full name'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_content 'Date of birth 10 February 1986 Change Date of birth'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_content 'Applicant over 16 Yes'
  expect(summary_page.content.summary_section[0].list_row[3].text).to have_content 'National Insurance number JR 05 40 08 D Change National Insurance number'
  expect(summary_page.content.summary_section[0].list_row[4].text).to have_content 'Status Single Change Status'
end
