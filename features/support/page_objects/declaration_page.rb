class DeclarationPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/declaration}

  section :content, '#content' do
    element :header, 'h1', text: 'Declaration and statement of truth'
    element :application_statement_signed_by_applicant, '.label', text: 'Applicant'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

  def sign_by_applicant
    find('#application_statement_signed_by_applicant', visible: false).click
    content.next.click
  end

end
