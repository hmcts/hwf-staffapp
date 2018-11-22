class SignInPage < BasePage
  include Warden::Test::Helpers
  Warden.test_mode!
  
  set_url '/'

  section :content, '#content' do
    element :user_email, '#user_email'
    element :user_password, '#user_password'
    element :sign_in_button, 'input[value="Sign in"]'
    element :alert, '.alert-box', text: 'You need to sign in before continuing.'
  end

  def sign_in
    content.sign_in_button.click
  end

  def admin_account
    binding.pry
    content.user_email.set ''
    content.user_password.set ''
    sign_in
  end

  def user_account
    content.user_email.set ''
    content.user_password.set ''
    sign_in
  end
end