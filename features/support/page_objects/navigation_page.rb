class NavigationPage < BasePage
  section :navigation_link, '.govuk-header__content' do
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

  def go_to_homepage
    navigation_link.help_with_fees_home.click
  end

  def sign_out
    navigation_link.sign_out.click
  end
end
