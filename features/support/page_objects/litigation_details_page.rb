class LitigationDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Litigation friend details'
    element :error, '.error', text: 'Enter the applicant\'s litigation friend details'
  end

  def submit_litigation_details
    fill_in "As the applicant is under the age of 16, please provide the Litigation Friend's name", with: 'name, address, telephone'
    next_page
  end

  def go_to_litigation_details_page
    start_application
    personal_details_page.full_name
    personal_details_page.under_16_dob
    personal_details_page.content.status_single.click
    next_page
  end
end
