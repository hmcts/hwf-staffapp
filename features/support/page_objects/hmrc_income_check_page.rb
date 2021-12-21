class HmrcIncomeCheckPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'For HMRC income checking'
  end
end
