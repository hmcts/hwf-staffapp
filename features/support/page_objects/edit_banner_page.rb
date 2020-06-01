class EditBannerPage < BasePage
  set_url '/notifications/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Edit Notifications Message'
    element :input_box_label, '.govuk-label', text: 'Message'
    element :show_message_checkbox, '.govuk-label', text: 'Show on admin homepage'
    element :notification_banner, '#notification'
  end

  def fill_in_ckeditor(id, with:)
    within_frame find("#cke_#{id} iframe") do
      find('body').base.send_keys with
    end
  end
end
