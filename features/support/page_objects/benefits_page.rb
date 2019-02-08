class BenefitsPage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Benefits'
    element :no, 'label', text: 'No'
    element :yes, 'label', text: 'Yes'
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
