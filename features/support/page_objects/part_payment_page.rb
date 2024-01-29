class PartPaymentPage < BasePage
  include ActionView::Helpers::NumberHelper
  set_url_matcher %r{/part_payments/[0-9]+}

  section :content, '#content' do
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
    element :header, 'h1', text: 'Is the part-payment ready to process?'
    element :evidence_confirmation_letter, '.evidence-confirmation-letter', text: 'We have received your part-payment towards your fee. However we are unable to accept it because:'
    element :part_payment_fee, '#result h2', text: 'The applicant must pay £40 towards the fee'
    element :not_received, 'span', text: 'What to do when a part payment has not been received'
    element :return_application_button, 'a', text: 'Return application'
    element :next, 'input[value="Next"]'
    element :back_to_start_link, 'a', text: 'Back to start'
    element :next_steps_header, 'h2', text: 'Next steps'
    element :next_steps_line_1, 'p', text: 'Write to applicant using the template provided'
    element :next_steps_line_2, 'p', text: 'Add the reference to the letter'
    element :next_steps_line_3, 'p', text: 'Post the letter and all the documents back to the applicant'
    element :see_guides, 'a', text: 'See the guides'
    element :waiting_for_part_payment_instance_heading, 'h1', text: /Waiting for part-payment$/
    element :start_now_button, 'a', text: 'Start now'
    sections :summary_section, 'dl' do
      elements :list_row, '.govuk-summary-list__row'
    end
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

  def click_next
    content.wait_until_next_visible
    content.next.click
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
    content.summary_section[2].has_text?("Jurisdiction #{jurisdiction_name}")
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

  def form_number(value)
    content.summary_section[2].has_text?("Form number #{value}")
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
    content.summary_section[3].has_text?("Benefits declared in application #{value}")
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


