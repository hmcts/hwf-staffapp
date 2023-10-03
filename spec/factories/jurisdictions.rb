FactoryBot.define do
  factory :jurisdiction do
    sequence(:name)   { "#{Faker::Company.name.gsub(/\W/, '')}#{Random.rand(1000)}" }
    sequence(:abbr)   { "#{Random.rand(1000)} #{Faker::Hacker.abbreviation} #{Random.rand(1000)}" }
    active { true }
    factory :invalid_jurisdiction do
      name { nil }
    end
  end
end
