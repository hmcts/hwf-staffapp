FactoryGirl.define do
  factory :detail do
    transient do
      application nil
    end

    factory :complete_detail do
      association :jurisdiction
      fee 310
      date_received Time.zone.today
      refund false
      probate nil
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
