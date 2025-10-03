Given('I am signed in as a smoke user') do
  page.driver.browser.url_blacklist = ['**/assets/**']
  visit 'users/sign_in'
  expect(page).to have_content('Sign in', wait: 10)

  sign_in_page.sign_in_as_smoke_user
end

Given('there is an online application that has not been processed') do
  pending # Write code here that turns the phrase above into concrete actions
end