class DashboardPage < BasePage
  section :content, '#content' do
    element :look_up_button, 'input[value="Look up"]'
    element :start_now_button, 'input[value="Start now"]'
    element :processed_applications, 'a', text: 'Processed applications'
    element :last_application, 'td', text: 'Smith'
    element :generate_reports_button, '.button', text: 'Generate reports'
    element :deleted_applications, 'a', text: 'Deleted applications'
    element :online_search_reference, '#online_search_reference'
  end

  def look_up_valid_reference
    content.online_search_reference.set 'valid'
    content.look_up_button.click
  end

  def look_up_invalid_reference
    content.online_search_reference.set 'invalid'
    content.look_up_button.click
  end

  def process_application
    content.start_now_button.click
  end

  def generate_reports
    content.generate_reports_button.click
  end
end
