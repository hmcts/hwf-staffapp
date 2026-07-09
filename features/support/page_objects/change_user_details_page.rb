class ChangeUserDetailsPage < BasePage
  set_url '/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
    elements :radio, '.govuk-radios__item'
    element :reader_radio, '#user_role_reader', visible: false
    element :role, 'p', text: 'Manager'
    element :county_radio, '.govuk-radios__item', text: 'County'
    element :save_changes_button, 'input[value="Save changes"]'
  end
end
