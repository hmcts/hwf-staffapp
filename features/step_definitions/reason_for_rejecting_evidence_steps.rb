And("I am on reason for rejecting the evidence page") do
  click_reference_link
  expect(evidence_page.content).to have_waiting_for_evidence_instance_header
  evidence_page.content.start_now_button.click
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.problem_with_evidence.click
  evidence_accuracy_page.click_next
  expect(reason_for_rejecting_evidence_page.content).to have_header
end

When("I successfully submit multiple reasons") do
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.content.wrong_type_provided.click
  reason_for_rejecting_evidence_page.content.unreadable_illegible.click
  reason_for_rejecting_evidence_page.content.pages_missing.click
  reason_for_rejecting_evidence_page.content.cannot_identify_applicant.click
  reason_for_rejecting_evidence_page.content.wrong_date_range.click
  reason_for_rejecting_evidence_page.click_next
end

When("I successfully submit a single reason") do
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.click_next
end

Then("I am taken to the summary page") do
  expect(summary_page.content).to have_header
end

Then("I should see my reasons for evidence on the summary page") do
  expect(summary_page.content).to have_evidence_header
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_text 'Ready to process No Change Ready to process'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Reasons Requested sources not provided, Wrong type provided, Unreadable or illegible, Pages missing, Cannot identify applicant, Wrong date range Change Reasons'
end

Then("I should see my reason for evidence on the summary page") do
  expect(summary_page.content).to have_evidence_header
  expect(summary_page.content.summary_section[0].list_row[0].text).to have_text 'Ready to process No Change Ready to process'
  expect(summary_page.content.summary_section[0].list_row[1].text).to have_text 'Reasons Requested sources not provided Change Reason'
end
