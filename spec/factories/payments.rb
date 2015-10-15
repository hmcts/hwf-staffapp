FactoryGirl.define do
  factory :payment do
    application
    expires_at { rand(3..7).days.from_now }
  end
end
