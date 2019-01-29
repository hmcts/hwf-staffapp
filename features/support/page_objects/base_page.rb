class BasePage < SitePrism::Page
  section :content, '#content' do
    element :next_button, 'input[value="Next"]'
  end
end
