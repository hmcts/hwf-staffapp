class BasePage < SitePrism::Page
  section :content, '#content' do
    element :next_button, 'input[value="Next"]'
    element :complete_processing_button, 'input[value="Complete processing"]'
    element :select_from_list_error, '.error', text: 'Select from at least one of the following options'
  end
end
