module ApplicationHelper
  def hide_login_menu?(current_page)
    current_page.in?(['/users/sign_in', '/users/password/edit'])
  end

  def markdown(source)
    renderer = ::Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    options = Rails.application.config.redcarpet_markdown_options
    ::Redcarpet::Markdown.new(renderer, options).render(source)
  end
end
