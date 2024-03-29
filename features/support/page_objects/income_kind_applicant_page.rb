class IncomeKindApplicantPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/income_kind_applicants}

  section :content, '#content' do
    element :header, 'h1', text: 'Type of income the applicant is receiving'
    elements :checkboxes, '.govuk-checkboxes label'
    element :next, 'input[value="Next"]'
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end

end
