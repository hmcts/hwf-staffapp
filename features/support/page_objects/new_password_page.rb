class NewPasswordPage < BasePage
  set_url '/users/password/new'

  section :content, '#content' do
    element :header, 'h2', text: 'Get a new password'
  end
end
