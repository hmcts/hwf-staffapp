class ProcessOnlineApplicationPage < BasePage
  set_url '/online_applications/1/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Application details'
    element :court_fee, '#online_application_fee[value="450.0"]'
    element :day_input, '#online_application_day_date_received[value="23"]'
    element :month_input, '#online_application_month_date_received[value="6"]'
    element :year_input, '#online_application_year_date_received[value="2020"]'
    element :form_number, '#online_application_form_name[value="ABC123"]'
  end
end
