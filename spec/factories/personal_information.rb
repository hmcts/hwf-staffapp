FactoryBot.define do
  factory :personal_information, class: 'Forms::Application::Applicant' do
    last_name { 'Faa' }
    first_name { 'Foo' }
    day_date_of_birth { '01' }
    month_date_of_birth { '01' }
    year_date_of_birth { '1980' }
    married { false }

    partner_first_name { 'Faa' }
    partner_last_name { 'Foo' }
    partner_date_of_birth { '01/01/1980' }

    factory :full_personal_information do
      title { 'Mr' }
      ni_number { 'AA123456A' }
      first_name { 'Bar' }
    end
  end
end
