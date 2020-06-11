class ChangeUserDetailsPage < BasePage
  set_url '/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
    elements :radio, '.govuk-radios__item'
    element :user_radio, '.govuk-radios__item', text: 'User'
    element :manager_radio, '.govuk-radios__item', text: 'Manager'
    element :admin_radio, '.govuk-radios__item', text: 'Admin'
    element :mi_radio, '.govuk-radios__item', text: 'Mi', visible: false
    element :reader_radio, '.govuk-radios__item', text: 'Reader'
    element :role, 'p', text: 'Manager'
  end
end
