class ProcessedApplicationsPage < BasePage
  section :content, '#content' do
    element :header, 'h1'
    element :result, '#result'
    element :fifteen_per_page, 'a[href="/processed_applications?per_page=15"]'
    element :which_page, '.govuk-body'
    section :pagination_navigation, '#processed_application_pagination' do
      element :last_page, 'a:nth-last-child(2)'
      element :first_page, 'a:nth-child(2)'
      element :page_6_button, 'a[href="/processed_applications?page=6&per_page=15"]'
      element :next_page, '.next_page', text: 'Next'
      element :previous_page, '.previous_page', text: 'Previous'
    end
  end

  def select_fifteen_per_page
    content.fifteen_per_page.click
  end

  def click_last_page_number
    content.pagination_navigation.last_page.click
  end

  def click_first_page_number
    content.pagination_navigation.first_page.click
  end

  def click_next_page_button
    content.pagination_navigation.next_page.click
  end

  def click_previous_page_button
    content.pagination_navigation.previous_page.click
  end
end
