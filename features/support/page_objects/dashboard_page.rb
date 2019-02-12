class DashboardPage < BasePage
  element :welcome_user, '#proposition-menu', text: 'Welcome user'
  element :view_profile, 'a', text: 'View profile'
  element :view_office, 'a', text: 'View office'
  element :staff_guides, 'a', text: 'Staff Guides'
  section :content, '#content' do
    element :dwp_restored, '.dwp-restored', text: 'The connection with the DWP is currently working. Benefits based and income based applications can now be processed.'
    element :look_up_button, 'input[value="Look up"]'
    element :start_now_button, 'input[value="Start now"]'
    element :processed_applications, 'a', text: 'Processed applications'
    element :last_application, 'td', text: 'Smith'
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

  def search_valid_reference
    content.completed_search_reference.set 'valid'
    content.search_button.click
  end

  def process_application
    content.start_now_button.click
  end
end
