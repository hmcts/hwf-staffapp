class HoEvidenceCheckPage < BasePage
  set_url '/guide'

  section :content, '#content' do
    elements :your_last_application, '.govuk-table__row'
  end
end
