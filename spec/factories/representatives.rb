FactoryBot.define do
  factory :representative do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    organisation { Faker::Company.name.gsub(/\W/, '') }
  end
end
