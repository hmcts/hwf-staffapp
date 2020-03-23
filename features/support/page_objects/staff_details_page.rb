class StaffDetailsPage < SitePrism::Page
  section :content, '#content' do
    element :table_row, '.govuk-table__row', text: 'Full name Admin'
    element :user_updated, '.govuk-error-summary', text: 'User updated.'
  end
end
