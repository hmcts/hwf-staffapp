class EditBannerPage < BasePage
  set_url '/notifications/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Edit Notifications Message'
  end
end
