class NewPasswordPage < BasePage
  section :content, '#content' do
    element :new_password_header, 'h2', text: 'Get a new password'
  end
end
