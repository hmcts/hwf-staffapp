class CourtGraphsPage < BasePage
  set_url '/reports/graphs'

  section :content, '#content' do
    element :bristol_heading, 'h2', text: 'Bristol R1'
  end
end
