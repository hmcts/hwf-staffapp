FactoryBot.define do
  factory :representative do
    first_name { Faker::Name.first_name.gsub(/\W/, '') }
    last_name { Faker::Name.last_name.gsub(/\W/, '') }
    organisation { Faker::Company.name.gsub(/\W/, '') }
    position { 'assistant lawyer' }
  end
end
