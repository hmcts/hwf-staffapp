FactoryBot.define do
  factory :appeal do
    application
    completed_by factory: [:user]
    correct { false }
  end
end
