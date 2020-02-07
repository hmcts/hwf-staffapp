class DwpMessagePage < BasePage
  set_url '/dwp_warnings/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Choose the DWP message'
    element :offline_message, 'label', text: 'Display DWP check is down message'
    element :online_message, 'label', text: 'Display DWP check is working message'
    element :default_message, 'label', text: 'Use the default DWP check to display message'
    element :selected, 'input[checked="checked"][name="dwp_warning[check_state]"]', visible: false
    element :save_changes, 'input[value="Save changes"]'
    element :saved_alert, '.govuk-error-summary', text: 'Your changes have been saved.'
  end

  def check_offline
    content.offline_message.click
  end

  def check_online
    content.online_message.click
  end

  def check_default
    content.default_message.click
  end

  def save_changes
    content.save_changes.click
  end
end
