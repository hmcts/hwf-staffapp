class DwpMessagePage < BasePage
  element :dwp_offline_banner, '.dwp-banner-offline', text: 'DWP CHECKERYou can’t check an applicant’s benefits. We’re investigating this issue.'
  element :dwp_online_banner, '.dwp-banner-online', text: 'DWP CHECKERYou can process benefits and income based applications.'
  section :content, '#content' do
    element :header, 'h2', text: 'Choose the DWP message'
    element :offline_message, 'label', text: 'Display DWP check is down message'
    element :online_message, 'label', text: 'Display DWP check is working message'
    element :default_message, 'label', text: 'Use the default DWP check to display message'
    element :selected, '.selected', text: 'Use the default DWP check to display message'
    element :save_changes, 'input[value="Save changes"]'
    element :saved_alert, '.alert-box', text: 'Your changes have been saved.'
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
