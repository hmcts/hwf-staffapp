FactoryGirl.define do
  factory :application do
    transient do
      ni_number nil
      applicant_factory :applicant
      applicant_traits []

      detail_traits []
      detail_factory :complete_detail
      fee '310.00'
      date_received Time.zone.today
      refund false
      date_fee_paid nil
      probate nil
      jurisdiction nil
      emergency_reason nil
    end

    sequence(:reference) { |n| "AB001-#{Time.zone.now.strftime('%y')}-#{n}" }
    benefits true
    dependents true
    children 1
    income 500
    threshold_exceeded false
    user
    association :completed_by, factory: :user
    completed_at Time.zone.today

    trait :uncompleted do
      completed_by_id nil
      completed_at nil
    end

    trait :undecided do
      decision nil
      decision_type nil
    end

    trait :benefit_type do
      application_type 'benefit'
    end

    trait :income_type do
      application_type 'income'
    end

    trait :probate do
      detail_traits [:probate]
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
      outcome 'full'
      application_type 'income'
    end

    trait :processed_state do
      decision { outcome }
      decision_type 'application'
      state :processed
    end

    trait :waiting_for_evidence_state do
      state :waiting_for_evidence
    end

    trait :waiting_for_part_payment_state do
      state :waiting_for_part_payment
    end

    trait :removed_state do
      decision { outcome }
      decision_type 'application'
      state :removed
    end

    factory :application_part_remission do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married]
      fee 410
      benefits false
      income 2000
      dependents true
      children 3
      outcome 'part'
      application_type 'income'
      amount_to_pay 100
    end

    factory :application_full_remission do
      applicant_factory :applicant_with_all_details
      applicant_traits [:married]
      fee 410
      benefits false
      income 10
      dependents true
      children 1
      outcome 'full'
      application_type 'income'
    end

    factory :application_no_remission do
      applicant_factory :applicant_with_all_details
      fee 410
      dependents false
      children 1
      income 3000
      outcome 'none'
      application_type 'income'
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

    after(:build) do |application, evaluator|
      build_related_for_application(self, :build, application, evaluator)
    end

    after(:stub) do |application, evaluator|
      around_stub(application) do
        build_related_for_application(self, :build_stubbed, application, evaluator)
      end
    end
  end
end
