class UsersPage < BasePage
  set_url '/users'

  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
  end
end
