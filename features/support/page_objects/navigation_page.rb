class NavigationPage < BasePage
  section :proposition_links, '#proposition-menu' do
    element :help_with_fees_home, 'a', text: 'Help with fees'
    element :welcome_user, 'li', text: 'Welcome user'
    element :view_profile, 'a', text: 'View profile'
    element :view_office, 'a', text: 'View office'
    element :view_staff, 'a', text: 'View staff'
    element :edit_banner, 'a', text: 'Edit banner'
    element :dwp_message, 'a', text: 'DWP message'
    element :staff_guides, 'a', text: 'Staff Guides'
    element :letter_templates, 'a', text: 'Letter templates'
    element :feedback, 'a', text: 'Feedback'
    element :sign_out, 'a', text: 'Sign out'
  end

  def go_to_dwp_message_page
    proposition_links.dwp_message.click
  end

  def go_to_homepage
    proposition_links.help_with_fees_home.click
  end

  def sign_out
    proposition_links.sign_out.click
  end
end
