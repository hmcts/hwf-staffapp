class HmrcMessagePage < BasePage
  set_url '/hmrc_warnings/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Choose the HMRC message'
    element :offline_message, 'label', text: 'Display HMRC check is down message'
    element :online_message, 'label', text: 'Display HMRC check is working message'
    element :default_message, 'label', text: 'Use the default HMRC check to display message'
    element :selected_default, 'input[checked="checked"][name="hmrc_warning[check_state]"][value="default_checker"]', visible: false
    element :save_changes, 'input[value="Save changes"]'
  end
end
