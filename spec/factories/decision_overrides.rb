FactoryBot.define do
  factory :decision_override do
    association :user
    reason { "My reasons" }

    after(:build) do |override|
      override.application ||= build(:application, decision_override: override)
    end

    after(:stub) do |override|
      around_stub(override) do
        override.application ||= build_stubbed(:application, decision_override: override)
      end
    end
  end
end
