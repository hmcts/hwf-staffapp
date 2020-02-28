class StaffPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Staff'
    element :filter_button, 'input[value="Filter"]'
    element :office_result, 'td.govuk-table__cell:nth-child(4)'
    element :activity_flag, 'td.govuk-table__cell:nth-child(6)', text: 'Active'
  end
end
