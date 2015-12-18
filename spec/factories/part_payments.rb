FactoryGirl.define do
  factory :part_payment do
    application
    expires_at { rand(3..7).days.from_now }

    factory :part_payment_part_outcome do
      outcome 'part'
    end

    factory :part_payment_none_outcome do
      outcome 'none'
    end

    trait :completed do
      completed_at Time.zone.yesterday
      association :completed_by, factory: :user
    end
  end
end
