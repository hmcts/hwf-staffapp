class RepresentativePage < BasePage
  set_url_matcher %r{/applications/[0-9]+/representative}

  section :content, '#content' do
    element :header, 'h1', text: 'Representative details'
    element :first_name, '#application_first_name'
    element :last_name, '#application_last_name'
    element :organisation, '#application_organisation'
    element :next, 'input[value="Next"]'
  end
  
  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def submit_representative_details
    content.wait_until_first_name_visible
    content.first_name.set('John')
    content.last_name.set('Smith')
    content.organisation.set('Legal Firm')
    click_next
  end
end
