class FindApplicationPage < BasePage
  section :content, '#content' do
    element :search_header, 'h2', text: 'Find an application'
    element :search_button, 'input[value="Search"]'
    element :no_results_found_error, '.error', text: 'No results found'
    element :processed_by_another_office, '.error', text: 'This application has been processed by '
    element :cant_be_blank_error, '.error', text: 'Enter a search term'
    element :search_results_header, 'h3', text: 'Search results'
    section :search_results_group, '.search-results' do
      element :sort_reference, 'a', text: 'Reference'
      element :sort_entered, 'a', text: 'Entered'
      element :sort_first_name, 'a', text: 'First name'
      element :sort_last_name, 'a', text: 'Last name'
      element :sort_case_number, 'a', text: 'Case number'
      element :sort_fee, 'a', text: 'Fee'
      element :sort_remission, 'a', text: 'Remission'
      element :sort_completed, 'a', text: 'Completed'
      section :found_application, 'tbody' do
        elements :result, 'tr'
      end
    end
    element :completed_search_reference, '#completed_search_reference'
    element :pagination_info, '.pagination pagination-info'
    element :pagination, '.pagination'
    element :next_page, '.next_page', text: 'Next'
    element :previous_page, '.previous_page', text: 'Previous'
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

  def search_case_number(case_number)
    content.completed_search_reference.set case_number
    content.search_button.click
  end

  def search_ni_number
    content.completed_search_reference.set 'JR054008D'
    content.search_button.click
  end

  def search_invalid_reference
    content.completed_search_reference.set 'invalid'
    content.search_button.click
  end

  def paginated_search_results
    sign_in_page.load_page
    sign_in_page.user_account_with_applications
    find_application_page.search_case_number('JK123456A')
  end

  def pagination_next_page
    content.next_page.click
  end

  def pagination_previous_page
    content.previous_page.click
  end

  def sort_by_reference
    find_application_page.content.search_results_group.sort_reference.click
  end

  def sort_by_entered
    find_application_page.content.search_results_group.sort_entered.click
  end

  def sort_by_first_name
    find_application_page.content.search_results_group.sort_first_name.click
  end

  def sort_by_last_name
    find_application_page.content.search_results_group.sort_last_name.click
  end

  def sort_by_case_number
    find_application_page.content.search_results_group.sort_case_number.click
  end

  def sort_by_fee
    find_application_page.content.search_results_group.sort_fee.click
  end

  def sort_by_remission
    find_application_page.content.search_results_group.sort_remission.click
  end

  def sort_by_completed
    find_application_page.content.search_results_group.sort_completed.click
  end
end
