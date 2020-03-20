class ProfilePage < BasePage
  set_url '/users/1'

  section :content, '#content' do
    element :header, 'h1', text: 'Staff details'
    element :profile, '.govuk-table'
    element :notice, '.notice'
  end
end
