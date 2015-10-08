FactoryGirl.define do
  factory :evidence_check do
    application
    expires_at { rand(3..7).days.from_now }
    outcome nil
    amount_to_pay nil
  end
end
