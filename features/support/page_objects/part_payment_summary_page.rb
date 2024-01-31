class PartPaymentSummaryPage < BasePage
  include ActionView::Helpers::NumberHelper
  set_url_matcher %r{/part_payments/[0-9]+/summary}

  section :content, '#content' do
    element :header, 'h1', text: 'Is the part-payment ready to process?'
    sections :summary_section, 'dl' do
      elements :list_row, '.govuk-summary-list__row'
    end
    element :complete, 'input[value="Complete processing"]'
  end

  def ready_to_process_payment
    content.wait_until_yes_visible
    content.yes.click
    click_next
  end

  def not_ready_to_process_payment
    content.wait_until_no_visible
    content.no.click
    fill_in 'Describe the problem with the part-payment', with: 'No signature on cheque'
    click_next
  end

  def complete_processing
    content.complete.click
  end

  def start_processing
    content.start_now_button.click
  end

  def current_application
    id = current_url[%r{/(\d+)}, 1]
    PartPayment.find(id).application
  end

  def jurisdiction
    jurisdiction_name = current_application.detail.jurisdiction.name
    content.summary_section[3].has_text?("Jurisdiction #{jurisdiction_name}")
  end

  def date_received(date)
    formatted_date = date.to_fs(:gov_uk_long)
    content.summary_section[1].has_text?("Date received #{formatted_date}")
  end

  def refund(value)
    content.summary_section[1].has_text?("Refund request #{value}")
  end

  def full_name(name)
    content.summary_section[2].has_text?("Full name #{name}")
  end

  def dob(value)
    content.summary_section[2].has_text?("Date of birth #{value}")
  end

  def marriage_status(value)
    content.summary_section[2].has_text?("Status #{value}")
  end

  def fee(value)
    content.summary_section[3].has_text?("Fee £#{value}")
  end

  def form_number(value)
    content.summary_section[3].has_text?("Form number #{value}")
  end

  def saving_less(value)
    # not there yet - this is example of incomsistent data displayed
    # content.summary_section[3].has_text?("Less than £4,250 #{value}")
    true
  end

  def saving_between(value)
    # not there yet - this is example of incomsistent data displayed
    # content.summary_section[3].has_text?("Between £4,250 and £15,999 #{value}")
    true
  end

  def saving_more(value)
    # not there yet - this is example of incomsistent data displayed
    # content.summary_section[3].has_text?("More than £16,000 #{value}")
    true
  end

  def benefits(value)
    # inconsistency no benefits on this page
    # content.summary_section[3].has_text?("Benefits declared in application #{value}")
    true
  end

  def children(value)
    # inconsistency
    # content.summary_section[4].has_text?("Applicant has children living with them or that they are financially supporting #{value}")
    text = (value == 'No') ? 0 : current_application.children
    content.summary_section[4].has_text?("Number of children #{text}")
  end

  def income(value)
    formatted_string = value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    # inconsistency
    # content.summary_section[4].has_text?("Income £#{value}")
    content.summary_section[4].has_text?("Total monthly income £#{formatted_string}")
  end

  def income_period(value)
    content.summary_section[4].has_text?("Income period #{value}")
  end

  def income_type(value)
    # inconsistency
    # content.summary_section[6].has_text?("Applicant's income type #{value}")
    content.summary_section[4].has_text?("Income kind applicant #{value}")
  end

  def declaration(value)
    content.summary_section[5].has_text?("Declaration and statement of truth signed by #{value}")
  end

end


