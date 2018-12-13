class UserDashboardPage < BasePage
  element :welcome_user, '#proposition-menu', text: 'Welcome user'
  element :view_profile, 'a', text: 'View profile'
  element :staff_guides, 'a', text: 'Staff Guides'
  section :content, '#content' do
    element :dwp_restored, '.dwp-restored', text: 'The connection with the DWP is currently working. Benefits based and income based applications can now be processed.'
    element :processed_applications, 'a', text: 'Processed applications'
    element :deleted_applications, 'a', text: 'Deleted applications'
    element :online_search_reference, '#online_search_reference'
    element :look_up_button, 'input[value="Look up"]'
    element :completed_search_reference, '#completed_search_reference'
    element :search_button, 'input[value="Search"]'
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
end
