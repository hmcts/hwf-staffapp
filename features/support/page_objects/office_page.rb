class OfficePage < BasePage
  set_url '/offices/1'

  section :content, '#content' do
    element :header, 'h1', text: 'Office details'
  end
end
