class ApplicationSearchPage < BasePage
  section :content, '#content' do
    element :search_header, 'h2', text: 'Find an application'
    element :search_button, 'input[value="Search"]'
    element :no_results_found_error, '.error', text: 'No results found.'
    element :cant_be_blank_error, '.error', text: 'Enter a search term'
    element :search_results_header, 'h3', text: 'Search results'
    section :search_results_group, '.search-results' do
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
    application_search_page.search_case_number('JK123456A')
  end

  def pagination_next_page
    content.next_page.click
  end

  def pagination_previous_page
    content.previous_page.click
  end
end
