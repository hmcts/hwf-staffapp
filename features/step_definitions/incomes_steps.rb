Given("I am on the incomes part of the application") do
  incomes_page.go_to_incomes_page
  expect(incomes_page).to be_displayed
  expect(incomes_page.content).to have_header
  expect(incomes_page.content).to have_question
end

When("I answer yes to does the applicant financially support any children") do
  incomes_page.content.yes.click
end

When("I answer no to does the applicant financially support any children") do
  incomes_page.submit_incomes_no
end

When("I submit the total number of children") do
  fill_in 'Number of children (add number given in questions 10 and 11 together)', with: '2'
end

When("I submit the total monthly income") do
  incomes_page.submit_incomes_1200
end
