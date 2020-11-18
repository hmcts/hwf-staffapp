class ProfilePage < BasePage
  set_url_matcher %r{/users/[0-9]+}

  section :content, '#content' do
    element :header, 'h1', text: 'Staff details'
    element :profile, '.govuk-table'
    element :notice, '.notice'
  end
end
