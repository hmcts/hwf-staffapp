class BasePage < SitePrism::Page
  section :content, '#content' do
    element :next_button, 'input', text: 'Next'
    element :complete_processing_button, 'input[value="Complete processing"]', visible: false
    element :select_from_list_error, '.error', text: 'Select a reason or reasons why you are rejecting the evidence'
    element :saved_alert, '.govuk-error-summary', text: 'Your changes have been saved.'
  end
  section :footer, '.govuk-footer__navigation' do
    element :see_the_guides_link, 'a', text: 'See the guides'
  end
end
