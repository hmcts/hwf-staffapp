class ApprovePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Ask a manager'
    element :first_name, '#application_fee_manager_firstname'
    element :last_name, '#application_fee_manager_lastname'
    element :error_first_name, 'label', text: 'Enter a manager\'s first name'
    element :error_last_name, 'label', text: 'Enter a manager\'s last name'
    element :next, 'input[value="Next"]'
  end

  def submit_full_name
    content.wait_until_first_name_visible
    content.first_name.set 'Mary'
    content.wait_until_last_name_visible
    content.last_name.set 'Smith'
    click_next
  end

  def submit_first_name
    content.wait_until_first_name_visible
    content.first_name.set 'Mary'
    click_next
  end

  def submit_last_name
    content.wait_until_last_name_visible
    content.last_name.set 'Smith'
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
