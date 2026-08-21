require 'axe/matchers/be_axe_clean'

# The Service Standard requires all services to meet level AA of the Web Content
# Accessibility Guidelines 2.2 (WCAG 2.2)
# [https://www.gov.uk/service-manual/helping-people-to-use-your-service/testing-for-accessibility]
WCAG_22_AA = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'].freeze

def axe_clean_to_wcag_22_aa(exclude = nil)
  Axe::Matchers.be_axe_clean.according_to(WCAG_22_AA).excluding(*String(exclude).split(/,\s*/))
end

Then("the {string} page should meet accessibility standards") do |_page_name|
  expect(page).to axe_clean_to_wcag_22_aa
end

Then("the {string} page should meet accessibility standards excluding {string}") do |_page_name, exclude|
  expect(page).to axe_clean_to_wcag_22_aa(exclude)
end

And("the error summary on the {string} page should link to the fields in error") do |_page_name|
  expect(error_summary_page).to be_shown

  field_ids = error_summary_page.linked_field_ids
  expect(field_ids).to be_any

  field_ids.each do |id|
    expect(page).to have_css("##{id}", visible: :all)
  end
end

When("I visit the dashboard page") do
  expect(dashboard_page).to be_displayed
end

Then("I should be on the generate reports page") do
  expect(reports_page).to be_displayed
  expect(reports_page.content).to have_management_information_header
end

Given("there are other members of staff") do
  staff_page.set_up_multiple_users
end

Given("a user has left feedback") do
  FactoryBot.create(:feedback, experience: 'Top quality experience', ideas: 'No it is perfect, well done', rating: 5)
end

When("I open the details of another member of staff") do
  click_link 'user'
  expect(staff_details_page.content).to have_header
end

When("I open the change details page for that member of staff") do
  staff_details_page.content.change_details_link.click
  expect(change_user_details_page.content).to have_header
end

When("I start to process the part-payment") do
  part_payment_page.content.start_now_button.click
  expect(part_payment_page.content).to have_header
end

When("I confirm the part-payment is ready to process") do
  part_payment_page.ready_to_process_payment
  expect(summary_page.content).to have_header
end

When("I continue from the evidence result page") do
  evidence_result_page.click_next
  expect(summary_page.content).to have_header
end

When("I submit my personal details as a married applicant") do
  personal_details_page.submit_all_personal_details_ni_married
end

Then("I should be taken to the partner details page") do
  expect(partner_details_page.content).to have_header
end

When("I submit the partner details") do
  partner_details_page.submit_partner_details
end

Then("I should be taken to the partner income type page") do
  expect(income_kind_partner_page.content).to have_header
end

When("I choose wages for the partner") do
  income_kind_partner_page.submit_wages
end

When("I fill in the application details with a fee over the approval limit") do
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_10001
end

Then("I should be taken to the ask a manager page") do
  expect(approve_page.content).to have_header
end

Given("the DWP benefit check will not respond") do
  stub_dwp_response_as_bad_request
end

When("I submit my personal details with a National Insurance number") do
  personal_details_page.submit_all_personal_details_ni_with_no_answer_for_benefits
end

When("I sign the declaration as a legal representative") do
  declaration_page.sign_declaration_as_legal_representative
end

Then("I should be taken to the representative page") do
  expect(representative_page.content).to have_header
end

When("I submit the representative details") do
  representative_page.submit_representative_details
end
