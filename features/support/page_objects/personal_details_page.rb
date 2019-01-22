class PersonalDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Personal details'
    element :application_last_name, '#application_last_name'
    element :last_name_error, '.field_with_errors', text: 'Enter the applicant\'s last name'
    element :application_date_of_birth, '#application_date_of_birth'
    element :date_of_birth_error, '.error', text: 'Enter a valid date of birth'
    element :status_single, '.block-label', text: 'Single'
    element :status_married, '.block-label', text: 'Married or living with someone and sharing an income'
  end

  def submit_required_information
    content.application_last_name.set 'Smith'
    content.application_date_of_birth.set '10.02.1986'
    content.status_single.click
    next_page
  end
end
