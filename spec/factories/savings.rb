FactoryBot.define do
  factory :saving do
    min_threshold { 3000 }
    min_threshold_exceeded { true }
    max_threshold { 16000 }
    max_threshold_exceeded { false }
    amount { 3500 }
    passed { true }
    fee_threshold { 4000 }
    over_61 { false }

    factory :saving_blank do
      min_threshold { nil }
      min_threshold_exceeded { nil }
      max_threshold { nil }
      max_threshold_exceeded { nil }
      amount { nil }
      passed { nil }
      fee_threshold { nil }
      over_61 { nil }
    end

    factory :saving_with_amount do
      amount { 3500 }
    end

    trait :above_maximum_threshold do
      max_threshold_exceeded { true }
      passed { false }
    end

    trait :below_minimum_threshold do
      min_threshold_exceeded { false }
      amount { nil }
    end

    after(:build) do |saving|
      saving.application ||= build(:application, saving: saving)
    end
  end
end
