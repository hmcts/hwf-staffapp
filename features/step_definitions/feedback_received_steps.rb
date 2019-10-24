And("feedback has been left by a user") do
  feedback_page.add_feedback_for_admin
end

And("I am on the feedback received page") do
  navigation_page.navigation_link.feedback.click
  expect(current_path).to end_with '/feedback/display'
  expect(feedback_page.content).to have_admin_feedback_header
end

Then("I should see the feedback received") do
  expect(feedback_page.content).to have_table_headers
  expect(feedback_page.content.user['href']).to include 'mailto'
  expect(feedback_page.content.cell_item[1].text).to eq 'Top quality experience'
  expect(feedback_page.content.cell_item[2].text).to eq 'No it is perfect, well done'
  expect(feedback_page.content.cell_item[3].text).to eq '5'
end
