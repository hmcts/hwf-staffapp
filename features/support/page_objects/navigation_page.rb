class NavigationPage < BasePage
  section :proposition_links, '#proposition-menu' do
    element :welcome_user, 'li', text: 'Welcome user'
    element :view_profile, 'a', text: 'View profile'
    element :view_office, 'a', text: 'View office'
    element :view_staff, 'a', text: 'View staff'
    element :edit_banner, 'a', text: 'Edit banner'
    element :dwp_message, 'a', text: 'DWP message'
    element :staff_guides, 'a', text: 'Staff Guides'
    element :letter_templates, 'a', text: 'Letter templates'
    element :feedback, 'a', text: 'Feedback'
  end

  def go_to_dwp_message_page
    proposition_links.dwp_message.click
  end
end
