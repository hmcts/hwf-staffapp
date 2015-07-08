FactoryGirl.define do
  factory :jurisdiction do
    name { |n| "#{Faker::Company.name}#{n}" }
    abbr { |n| "#{Faker::Hacker.abbreviation} #{n}" }
    active true
    factory :invalid_jurisdiction do
      name nil
    end
  end
end
