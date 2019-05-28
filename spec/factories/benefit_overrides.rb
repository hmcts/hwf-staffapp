FactoryBot.define do
  factory :benefit_override do
    correct { false }
    association :completed_by, factory: :user
  end
end
