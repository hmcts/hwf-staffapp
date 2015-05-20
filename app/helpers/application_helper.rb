module ApplicationHelper
  def hide_login_menu?(current_page)
    current_page.in?(['/users/sign_in', '/users/password/edit'])
  end
end
