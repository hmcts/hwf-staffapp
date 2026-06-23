FactoryBot.define do
  factory :jurisdiction do
    # rails_helper calls FactoryBot.reload before
    # each example, which resets sequences and would collide with records that
    # outlive a single example (e.g. let_it_be).
    name { "#{Faker::Company.name.gsub(/\W/, '')}#{SecureRandom.hex(8)}" }
    abbr { "#{Faker::Hacker.abbreviation}#{SecureRandom.hex(8)}" }
    active { true }
    factory :invalid_jurisdiction do
      name { nil }
    end
  end
end
