FactoryGirl.define do
  factory :personal_information, class: Applikation::Forms::PersonalInformation do
    last_name 'Foo'
    date_of_birth '01/01/1980'
    married false

    factory :full_personal_information do
      title 'Mr'
      ni_number 'AA123456A'
      first_name 'Bar'
    end
  end
end
