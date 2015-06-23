FactoryGirl.define do
  factory :jurisdiction do
    name { Faker::Company.name }
    abbr { |n| "#{Faker::Hacker.abbreviation} #{n}" }
    active true
  end
end
