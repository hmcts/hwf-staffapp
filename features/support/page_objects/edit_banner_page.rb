class EditBannerPage < BasePage
  set_url '/notifications/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Edit Notifications Message'
    element :input_box_label, '.govuk-label', text: 'Message'
    element :show_message_checkbox, '.govuk-label', text: 'Show on admin homepage'
    element :notification_banner, '#notification'
    element :editor, '.trix-content'
  end

  def fill_in_editor(with:)
    within(content.editor) do
      page.execute_script("document.querySelector('trix-editor').editor.loadHTML('#{with}')")
    end
  end
end
