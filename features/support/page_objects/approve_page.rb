class ApprovePage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Ask a manager'
    element :first_name, '#application_fee_manager_firstname'
    element :last_name, '#application_fee_manager_lastname'
    element :error_first_name, 'label', text: 'Enter a manager\'s first name'
    element :error_last_name, 'label', text: 'Enter a manager\'s last name'
  end

  def go_to_approve_page
    start_application
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_1001
  end

  def submit_full_name
    content.first_name.set 'Mary'
    content.last_name.set 'Smith'
    next_page
  end
end
