Then("I look at the result on the processed application page") do
  expect(application_page.content.summary_section[3]).to have_result_header
end

Then("I should see the result for savings on the processed application page") do
  expect(application_page.content.summary_section[3]).to have_savings_question
  expect(application_page.content.summary_section[3]).to have_savings_passed
end

Then("I should see the result for benefits on the processed application page") do
  expect(application_page.content.summary_section[3]).to have_benefits_question
  expect(application_page.content.summary_section[3]).to have_benefits_passed
end

Then("I look at the result on the confirmation page") do
  expect(application_page.content.summary_section[0]).to have_result_header
end

Then("I should see the result for savings and investments on the confirmation page") do
  expect(application_page.content.summary_section[0]).to have_savings_investments_question
  expect(application_page.content.summary_section[0]).to have_savings_passed
end

Then("I should see the result for benefits on the confirmation page") do
  expect(application_page.content.summary_section[0]).to have_benefits_question
  expect(application_page.content.summary_section[0]).to have_benefits_passed
end

When("I see benefit summary") do
  expect(application_page.content.summary_section[3]).to have_benefits_header
end

Then("I should see declared benefits in this application") do
  expect(application_page.content.summary_section[3]).to have_benefits_question
  expect(application_page.content.summary_section[3]).to have_answer_yes
end

Then("I have provided the correct evidence") do
  expect(application_page.content.summary_section[3]).to have_evidence_question
  expect(application_page.content.summary_section[3]).to have_answer_yes
end
