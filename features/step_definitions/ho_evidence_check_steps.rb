Given("the applicant has a home office number") do
  sign_in_page.load_page
  sign_in_page.user_account
  ho_application
end

And("the first application is a refund application") do
  refund_application
end

When("a second application is processed with the same home office number") do
  ho_application
  refund_application
end

Then("the first application will be processed") do
  expect(ho_evidence_check_page.content.your_last_application[2].text).to have_content 'processed Mr John Christopher Smith'
end

But("the second application will require evidence") do
  expect(ho_evidence_check_page.content.your_last_application[1].text).to have_content 'waiting_for_evidence Mr John Christopher Smith'
end
