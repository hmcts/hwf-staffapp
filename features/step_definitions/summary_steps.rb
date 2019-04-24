Given("I have completed an application") do
  summary_page.go_to_summary_page
end

Given("I am on the summary page") do
  expect(current_path).to include 'summary'
  expect(summary_page.content).to have_header
end

When("I successfully submit my application") do
  summary_page.complete_processing
end

Then("I should be taken to the confirmation page") do
  expect(current_path).to include 'confirmation'
  expect(confirmation_page.content).to have_eligible
end

When("I see benefit summary") do
  expect(summary_page.content.summary_section[3]).to have_benefits_header
end

Then("I should see I have declared benefits in this application") do
  expect(summary_page.content.summary_section[3]).to have_benefits_question
  expect(summary_page.content.summary_section[3]).to have_answer_yes
end

Then("I have provided the correct evidence") do
  expect(summary_page.content.summary_section[3]).to have_evidence_question
  expect(summary_page.content.summary_section[3]).to have_answer_yes
end

When("I click on change benefits") do
  summary_page.content.summary_section[3].change_benefits.click
end

When("I change my answer to no") do
  benefits_page.submit_benefits_no
end

Then("I should see that my new answer is displayed in the benefit summary") do
  incomes_page.submit_incomes_no
  expect(summary_page.content.summary_section[3]).to have_answer_no
end
