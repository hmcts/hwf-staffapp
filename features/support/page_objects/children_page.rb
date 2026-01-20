class ChildrenPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/dependents}

  section :content, '#content' do
    element :header, 'h1', text: 'Children'
    elements :radio, '.govuk-radios label'

    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def no_children
    content.radio[0].click
    content.next.click
  end

  def yes_children
    content.radio[1].click
    # find()
    content.next.click
  end

end
