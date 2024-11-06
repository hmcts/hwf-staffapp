class ProcessOnlineApplicationPage < BasePage
  section :content, '#content' do
    element :application_details_header, 'h1', text: 'Application details', visible: false
    element :check_details_header, 'h1', text: 'Check details', visible: false
    element :not_eligible_header, 'h2', text: '✗ Not eligible for help with fees', visible: false
    elements :summary_row, '.govuk-summary-list__row'
    elements :last_application, '.govuk-table__row'
    sections :group, '.group-level' do
      elements :input, 'input'
    end
    element :jurisdiction, '.govuk-radios__item label.govuk-radios__label'
    element :form_input, '#online_application_form_name'
    element :error, '.error', text: 'You must select a jurisdiction'
    element :reference_number_is, '.govuk-panel__body', text: 'Reference number'
    element :failed_benefits, '.govuk-summary-list__row', text: '✗ Failed'
    element :next, 'input[value="Next"]'
    element :back_to_start_button, 'a', text: 'Back to start'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def fill_in_date_application_received
    date_received = Time.zone.today
    fill_in('Day', with: date_received.day)
    fill_in('Month', with: date_received.month)
    fill_in('Year', with: date_received.year)
  end

end
