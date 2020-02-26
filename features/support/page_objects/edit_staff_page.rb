class EditStaffPage < BasePage
  set_url '/users/1/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Change details'
  end
end
