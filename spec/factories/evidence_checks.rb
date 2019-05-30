FactoryGirl.define do
  factory :evidence_check do
    application
    expires_at { rand(3..7).days.from_now }
    incorrect_reason nil
    outcome nil
    amount_to_pay nil

    factory :evidence_check_full_outcome do
      correct true
      income 100
      outcome 'full'
    end

    factory :evidence_check_part_outcome do
      correct true
      income 100
      outcome 'part'
      amount_to_pay 50
    end

    factory :evidence_check_incorrect do
      correct false
      incorrect_reason 'SOME REASON'
      outcome 'none'
    end

    trait :completed do
      completed_at Time.zone.yesterday
      association :completed_by, factory: :user
    end
  end
end
