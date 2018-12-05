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
    user = User.first
    content.user_email.set user.email
    content.user_password.set 'password'
    sign_in
  end

  def user_account
    binding.pry
    office = FactoryGirl.create(:office)
    admin = FactoryGirl.create(:admin_user, office: office)
    manager = FactoryGirl.create(:manager, office: office)
    business_entity = office.business_entities.first
    content.user_email.set user_email
    content.user_password.set user_password
    sign_in
  end
end