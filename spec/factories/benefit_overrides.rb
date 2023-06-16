FactoryBot.define do
  factory :benefit_override do
    correct { false }
    completed_by factory: [:user]
  end
end
