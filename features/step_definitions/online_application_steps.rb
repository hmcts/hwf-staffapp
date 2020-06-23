Given("I have started to process an online application") do
  RSpec::Mocks.with_temporary_scope do
    binding.pry
    OnlineApplicationBuilder.stub
    sign_in_page.load_page
    sign_in_page.admin_account
  end
  expect(sign_in_page).to have_welcome_user
end