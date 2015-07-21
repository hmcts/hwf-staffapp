FactoryGirl.define do
  factory :application do
    title { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth Time.zone.today - 20.years
    ni_number "AB123456C"
    married false
  end
end
