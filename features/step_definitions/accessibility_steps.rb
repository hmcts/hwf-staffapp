require 'axe/matchers/be_axe_clean'

# WCAG 2.2 AA
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
  FactoryBot.create(:feedback)
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
