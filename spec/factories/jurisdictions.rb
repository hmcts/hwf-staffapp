FactoryBot.define do
  factory :jurisdiction do
    sequence(:name)   { "#{Faker::Company.name.delete(',')}#{Random.rand(1000)}" }
    sequence(:abbr)   { "#{Faker::Hacker.abbreviation} #{Random.rand(1000)}" }
    active { true }
    factory :invalid_jurisdiction do
      name { nil }
    end
  end
end
