FactoryGirl.define do
  factory :jurisdiction do
    name { Faker::Company.name }
    abbr { Faker::Hacker.abbreviation }
    active true
  end
end
