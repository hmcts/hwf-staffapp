FactoryGirl.define do
  factory :application do
    transient do
      ni_number nil
      applicant nil
      applicant_factory :applicant
      applicant_traits []

      detail nil
      detail_traits []
      fee '310.00'
      date_received Time.zone.today
      refund false
      probate nil
    end

    sequence(:reference) { |n| "AB001-#{Time.zone.now.strftime('%y')}-#{n}" }
    benefits true
    dependents true
    children 1
    income 500
    threshold_exceeded false
    user

    trait :probate do
      detail_traits [ :probate ]
    end

    trait :refund do
      refund true
      date_fee_paid Time.zone.yesterday
    end

    trait :no_benefits do
      benefits false
    end

    trait :confirm do
      benefits false
      application_outcome 'full'
      application_type 'income'
    end

    factory :application_part_remission do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married]
      fee 410
      benefits false
      income 2000
      dependents true
      children 3
    end

    factory :application_full_remission do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married]
      fee 410
      benefits false
      income 10
      dependents true
      children 1
    end

    factory :application_no_remission do
      applicant_factory :applicant_with_all_details
      fee 410
      dependents false
      children 1
      income 3000
    end

    factory :applicant_under_61 do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married, :under_61]
    end

    factory :married_applicant_under_61 do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married, :under_61]
    end

    factory :married_applicant_over_61 do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married, :over_61]
    end

    after(:build, :stub) do |application, evaluator|
      if evaluator.applicant
        application.applicant = evaluator.applicant
      else
        application.applicant = build(evaluator.applicant_factory,
          *evaluator.applicant_traits, application: application, ni_number: evaluator.ni_number)
      end

      if evaluator.detail
        application.detail = evaluator.detail
      else
        overrides = { application: application }
        %i[fee date_received refund probate].each do |field|
          value = evaluator.send(field)
          overrides[field] = value if value.present?
        end

        application.detail = build(:detail,
          *evaluator.detail_traits, overrides)
      end
    end
  end
end
