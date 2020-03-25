class StaffDetailsPage < SitePrism::Page
  section :content, '#content' do
    elements :table_row, '.govuk-table__row'
    element :user_updated, '.govuk-error-summary', text: 'User updated.'
  end
end
