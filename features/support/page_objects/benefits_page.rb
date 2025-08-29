class BenefitsPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/incomes}

  section :content, '#content' do
    element :header, 'h1', text: 'Benefits the applicant is receiving'
    element :benefit_question, '.govuk-label', text: 'Is the applicant receiving one of these benefits?'
    element :no, 'label', text: 'No', visible: false
    element :yes, 'label', text: 'Yes', visible: false
    element :next, 'input[value="Next"]'
  end

  def submit_benefits_yes
    content.wait_until_yes_visible
    content.yes.click
    # Wait for radio button to be selected
    sleep(0.2)
    click_next
  end

  def submit_benefits_no
    content.wait_until_no_visible
    content.no.click
    # Wait for radio button to be selected
    sleep(0.2)
    click_next
  end

  def click_next
    content.wait_until_next_visible
    
    # Wait for any JavaScript to finish loading/executing
    sleep(0.5)
    
    # Use JavaScript click as backup if regular click fails in CI
    begin
      content.next.click
    rescue => e
      puts "Regular click failed (#{e.class}: #{e.message}), trying JavaScript click..."
      page.execute_script("document.querySelector('input[value=\"Next\"]').click()")
    end
    
    # Wait for page transition to begin
    sleep(1)
  end
end
