class StaffDetailsPage < SitePrism::Page
  set_url_matcher %r{/users/[0-9]+}

  section :content, '#content' do
    elements :table_row, '.govuk-table__row'
    element :user_updated, '.govuk-error-summary', text: 'User updated.'
  end
end
