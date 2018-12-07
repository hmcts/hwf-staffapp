class SignInPage < BasePage
  include Warden::Test::Helpers
  Warden.test_mode!
  
  set_url '/'

  element :welcome_test_user, 'span', text: 'Welcome Test User'
  element :welcome_test_manager, 'span', text: 'Welcome Test Manager'
  element :welcome_test_admin, 'span', text: 'Welcome Test Admin'
  section :content, '#content' do
    element :generate_reports, 'h3', text: 'Generate reports'
    element :view_offices, 'h3', text: 'View offices'
    element :waiting_for_evidence, 'h3', text: 'Waiting for evidence'
    element :waiting_for_part_payment, 'h3', text: 'Waiting for part-payment'
    element :your_last_applications, 'h3', text: 'Your last applications'
    element :completed_applications, 'h3', text: 'Completed'
    element :user_email, '#user_email'
    element :user_password, '#user_password'
    element :sign_in_button, 'input[value="Sign in"]'
    element :alert, '.alert-box', text: 'You need to sign in before continuing.'
  end

  def sign_in
    content.sign_in_button.click
  end

  def user_account
    user = User.second
    content.user_email.set user.email
    content.user_password.set 'password'
    sign_in
  end

  def manager_account
    manager = User.third
    content.user_email.set manager.email
    content.user_password.set 'password'
    sign_in
  end

  def admin_account
    admin = User.first
    content.user_email.set admin.email
    content.user_password.set 'password'
    sign_in
  end
end