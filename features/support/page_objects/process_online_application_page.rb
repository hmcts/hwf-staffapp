class ProcessOnlineApplicationPage < BasePage
  section :content, '#content' do
    element :application_details_header, 'h1', text: 'Application details', visible: false
    element :check_details_header, 'h1', text: 'Check details', visible: false
    element :not_eligible_header, 'h2', text: '✗ Not eligible for help with fees', visible: false
    elements :summary_row, '.govuk-summary-list__row'
    elements :last_application, '.govuk-table__row'
    sections :group, '.group-level' do
      elements :input, 'input'
      elements :jurisdiction, '.govuk-radios__item'
    end
    element :error, '.error', text: 'You must select a jurisdiction'
    element :failed_benefits, '.govuk-summary-list__row', text: '✗ Failed'
  end
end
