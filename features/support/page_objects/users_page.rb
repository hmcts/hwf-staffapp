class UsersPage < BasePage
  set_url '/users'

  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
    element :active_result, '.govuk-table__cell', text: 'Active'
    element :inactive_result, '.govuk-table__cell', text: 'Inactive'
    element :reader_role, '.govuk-table__cell', text: 'Reader'
  end
end
