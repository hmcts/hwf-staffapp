FactoryGirl.define do
  factory :evidence_check do
    application
    expires_at { rand(3..7).days.from_now }
  end
end
