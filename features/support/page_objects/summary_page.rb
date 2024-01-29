class SummaryPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/summary}

  section :content, '#content' do
    element :header, 'h1', text: 'Check details'
    element :personal_details_header, 'h2', text: 'Personal details'
    element :evidence_header, 'h2', text: 'Evidence'
    sections :summary_section, 'dl' do
      elements :list_row, '.govuk-summary-list__row'
      elements :list_key, '.govuk-summary-list__key'
      elements :list_actions, '.govuk-summary-list__actions'
      element :evidence_reason, '.govuk-summary-list__row', text: 'Reason Not arrived or too late'
      element :evidence_incorrect_reason_category, '.govuk-summary-list__row', text: 'Incorrect reason category Requested sources not provided, Wrong type provided, Unreadable or illegible, Pages missing, Cannot identify applicant, Wrong date range Change'
      element :change_benefits, 'a', text: 'Change Benefits declared in application'
      element :change_dob, 'a', text: 'Change Date of birth'
      element :change_date_received, 'a', text: 'Change Date received'
    end
     element :complete, 'input[value="Complete processing"]'
  end

  def complete_processing
    content.complete.click
  end

  def date_received(date)
    formatted_date = date.to_fs(:gov_uk_long)
    content.summary_section[0].has_text?("Date received #{formatted_date}")
  end

  def refund(value)
    content.summary_section[0].has_text?("Refund request #{value}")
  end

  def full_name(name)
    content.summary_section[1].has_text?("Full name #{name}")
  end

  def dob(value)
    content.summary_section[1].has_text?("Date of birth #{value}")
  end

  def marriage_status(value)
    content.summary_section[1].has_text?("Status #{value}")
  end

  def fee(value)
    content.summary_section[2].has_text?("Fee £#{value}")
  end

  def jurisdiction
    jurisdiction_name = current_application.detail.jurisdiction.name
    content.summary_section[2].has_text?("Jurisdiction #{jurisdiction_name}")
  end

  def form_number(value)
    content.summary_section[2].has_text?("Form number #{value}")
  end

  def current_application
    id = current_url[%r{/(\d+)/}, 1]
    Application.find(id)
  end

  def saving_less(value)
    content.summary_section[3].has_text?("Less than £4,250 #{value}")
  end

  def saving_between(value)
    content.summary_section[3].has_text?("Between £4,250 and £15,999 #{value}")
  end

  def saving_more(value)
    content.summary_section[3].has_text?("More than £16,000 #{value}")
  end

  def benefits(value)
    content.summary_section[4].has_text?("Benefits declared in application #{value}")
  end

  def children(value)
    content.summary_section[5].has_text?("Applicant has children living with them or that they are financially supporting #{value}")
  end

  def income(value)
    content.summary_section[6].has_text?("Income £#{value}")
  end

  def income_period(value)
    content.summary_section[6].has_text?("Income period #{value}")
  end

  def income_type(value)
    content.summary_section[6].has_text?("Applicant's income type #{value}")
  end

  def declaration(value)
    content.summary_section[7].has_text?("Declaration and statement of truth signed by #{value}")
  end
end
