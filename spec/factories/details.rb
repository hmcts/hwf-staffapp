FactoryGirl.define do
  factory :detail do
    transient do
      application nil
    end

    factory :complete_detail do
    end

    trait :probate do
      probate true
      deceased_name 'John Smith'
      date_of_death Time.zone.yesterday
    end

    trait :emergency do
      emergency_reason 'It can not wait'
    end

    after(:build, :stub) do |detail, evaluator|
      app = evaluator.application
      detail.application = app.present? ? app : build(:application, detail: detail)
    end
  end
end
