class BenefitsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Benefits'
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
  end

  def go_to_benefits_page
    personal_details_page.submit_required_personal_details
    application_details_page.submit_fee_600
    savings_investments_page.submit_less_than
  end

  def submit_benefits_yes
    content.yes.click
    next_page
  end

  def submit_benefits_no
    content.no.click
    next_page
  end
end
