class DashboardPage < BasePage
  element :welcome_user, '#proposition-menu', text: 'Welcome user'
  element :view_profile, 'a', text: 'View profile'
  element :view_office, 'a', text: 'View office'
  element :staff_guides, 'a', text: 'Staff Guides'
  section :content, '#content' do
    element :dwp_restored, '.dwp-restored', text: 'The connection with the DWP is currently working. Benefits based and income based applications can now be processed.'
    element :processed_applications, 'a', text: 'Processed applications'
    element :deleted_applications, 'a', text: 'Deleted applications'
    element :online_search_reference, '#online_search_reference'
    element :search_header, 'h2', text: 'Find an application'
    element :search_button, 'input[value="Search"]'
    element :no_results_found_error, '.error', text: 'You can\'t search "invalid". Enter the reference, applicant’s first or last name or case number.'
    element :cant_be_blank_error, '.error', text: 'Enter a search term'
    element :search_results_header, 'h3', text: 'Search results'
    section :search_results_group, '.search-results' do
      section :found_application, 'tbody' do
        elements :result_by_name, 'tr'
      end
    end
    element :completed_search_reference, '#completed_search_reference'
    element :look_up_button, 'input[value="Look up"]'
    element :start_now_button, 'input[value="Start now"]'
    element :last_application, 'td', text: 'Smith'
    element :generate_reports_button, '.button', text: 'Generate reports'
  end

  def look_up_valid_reference
    content.online_search_reference.set 'valid'
    content.look_up_button.click
  end

  def look_up_invalid_reference
    content.online_search_reference.set 'invalid'
    content.look_up_button.click
  end

  def search_valid_reference
    content.completed_search_reference.set 'valid'
    content.search_button.click
  end

  def search_invalid_reference
    content.completed_search_reference.set 'invalid'
    content.search_button.click
  end

  def search_by_last_name
    content.completed_search_reference.set 'Smith'
    content.search_button.click
  end

  def search_by_full_name
    content.completed_search_reference.set 'John Christopher Smith'
    content.search_button.click
  end

  def search_by_hwf_reference
    content.completed_search_reference.set 'PA19-000001'
    content.search_button.click
  end

  def search_case_number
    content.completed_search_reference.set 'E71YX571'
    content.search_button.click
  end

  def process_application
    content.start_now_button.click
  end

  def generate_reports
    content.generate_reports_button.click
  end
end
