And("I am on reason for rejecting the evidence page") do
  reason_for_rejecting_evidence_page.go_to_reason_for_rejecting_evidence_page
  expect(reason_for_rejecting_evidence_page.content).to have_header
end

When("I successfully submit multiple reasons") do
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.content.wrong_type_provided.click
  reason_for_rejecting_evidence_page.content.unreadable_illegible.click
  reason_for_rejecting_evidence_page.content.pages_missing.click
  reason_for_rejecting_evidence_page.content.cannot_identify_applicant.click
  reason_for_rejecting_evidence_page.content.wrong_date_range.click
  next_page
end

When("I successfully submit a single reason") do
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  next_page
end

Then("I am taken to the summary page") do
  expect(current_path).to end_with '/evidence/1/summary'
end

Then("I should see my reasons for evidence on the summary page") do
  expect(summary_page.content.summary_section[0]).to have_evidence_header
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Ready to process No Change Ready to process'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_text 'Reasons Requested sources not provided, Wrong type provided, Unreadable or illegible, Pages missing, Cannot identify applicant, Wrong date range Change Reasons'
end

Then("I should see my reason for evidence on the summary page") do
  expect(summary_page.content.summary_section[0]).to have_evidence_header
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Ready to process No Change Ready to process'
  expect(summary_page.content.summary_section[0].list_row[2].text).to have_text 'Reason Requested sources not provided Change Reason'
end
