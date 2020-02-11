FactoryBot.define do
  factory :jurisdiction do
    sequence(:name)   { |n| "#{Faker::Company.name.delete(',')}#{n}" }
    sequence(:abbr)   { |n| "#{Faker::Hacker.abbreviation} #{n}" }
    active { true }
    factory :invalid_jurisdiction do
      name { nil }
    end
  end
end
