FactoryGirl.define do
  factory :evidence_check do
    application
    expires_at { rand(3..7).days.from_now }
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
      outcome 'none'

      after(:build) do |evidence_check|
        build :reason, evidence_check: evidence_check
      end
    end
  end
end
