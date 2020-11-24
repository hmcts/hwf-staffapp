class OfficesPage < BasePage
  set_url '/offices'

  section :content, '#content' do
    element :header, 'h1', text: 'Offices'
  end
end
