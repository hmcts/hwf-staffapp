FactoryGirl.define do
  factory :payment do
    application
    expires_at { rand(3..7).days.from_now }

    trait :completed do
      completed_at Time.zone.yesterday
      association :completed_by, factory: :user
    end
  end
end
