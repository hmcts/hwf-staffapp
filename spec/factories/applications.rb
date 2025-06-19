FactoryBot.define do
  sequence(:reference_number) { |n| "AB001-#{Time.zone.now.strftime('%y')}-#{n}" }

  factory :application do
    transient do
      ni_number { "AB123#{Random.rand(9)}#{Random.rand(9)}#{Random.rand(9)}C" }
      ho_number { nil }
      date_of_birth { 20.years.ago }
      married { false }
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [] }
      detail_traits { [] }
      detail_factory { :complete_detail }
      fee { '310.00' }
      date_received { Time.zone.today }
      refund { false }
      date_fee_paid { nil }
      probate { nil }
      jurisdiction { nil }
      emergency_reason { nil }
      representative { association :representative, application: instance }
    end

    benefits { true }
    dependents { true }
    children { 1 }
    income { 500 }
    threshold_exceeded { false }
    user
    completed_by { user }
    completed_at { Time.zone.today }

    trait :applicant_full do
      applicant {
        association :applicant_with_all_details,
                    application: instance, ni_number: ni_number,
                    ho_number: ho_number,
                    date_of_birth: date_of_birth,
                    married: married
      }
    end

    trait :waiting_for_evidence_state do
      reference { generate(:reference_number) }
      state { :waiting_for_evidence }
      evidence_check { association :evidence_check, application: instance }
    end

    trait :with_business_entity do
      business_entity
    end

    trait :with_office do
      office
    end

    trait :with_reference do
      reference { generate(:reference_number) }
    end

    trait :uncompleted do
      completed_by_id { nil }
      completed_at { nil }
    end

    trait :undecided do
      decision { nil }
      decision_type { nil }
    end

    trait :benefit_type do
      application_type { 'benefit' }
    end

    trait :income_type do
      application_type { 'income' }
    end

    trait :probate do
      detail_traits { [:probate] }
    end

    trait :refund do
      refund { true }
      date_fee_paid { Time.zone.yesterday }
    end

    trait :no_benefits do
      benefits { false }
    end

    trait :confirm do
      benefits { false }
      reference { generate(:reference_number) }
      outcome { 'full' }
      application_type { 'income' }
    end

    trait :processed_state do
      reference { generate(:reference_number) }
      decision { outcome }
      decision_type { 'application' }
      state { :processed }
    end

    trait :waiting_for_part_payment_state do
      reference { generate(:reference_number) }
      state { :waiting_for_part_payment }
    end

    trait :deleted_state do
      reference { generate(:reference_number) }
      decision { outcome }
      decision_type { 'application' }
      state { :deleted }
      deleted_reasons_list { 'Typo/spelling error' }
      deleted_reason { 'I did not like it' }
      deleted_at { Time.zone.now }
      deleted_by factory: [:user]
    end

    factory :application_part_remission do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married] }
      fee { 410 }
      benefits { false }
      income { 2000 }
      dependents { true }
      children { 3 }
      children_age_band { { 'one' => '1', 'two' => '2' } }
      outcome { 'part' }
      application_type { 'income' }
      amount_to_pay { 100 }
      income_period { Application::INCOME_PERIOD[:last_month] }
    end

    factory :application_part_refund do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married] }
      fee { 410 }
      benefits { false }
      income { 2000 }
      dependents { true }
      children { 3 }
      outcome { 'part' }
      application_type { 'income' }
      amount_to_pay { 100 }
      refund { true }
      income_period { Application::INCOME_PERIOD[:last_month] }
    end

    factory :application_full_remission do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married] }
      reference { generate(:reference_number) }
      fee { 410 }
      benefits { false }
      income { 10 }
      dependents { true }
      children { 1 }
      outcome { 'full' }
      application_type { 'income' }
      decision_date { Time.zone.today }
      income_period { Application::INCOME_PERIOD[:last_month] }
    end

    factory :application_full_remission_ev do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married] }
      evidence_check { association :evidence_check, application: instance }
      reference { generate(:reference_number) }
      fee { 410 }
      benefits { false }
      income { 10 }
      dependents { true }
      state { 1 }
      children { 1 }
      outcome { 'full' }
      application_type { 'income' }
      decision_date { Time.zone.today }
      income_period { Application::INCOME_PERIOD[:last_month] }
    end

    factory :application_full_remission_nino do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married] }
      fee { 6000 }
      benefits { false }
      income { 1000 }
      dependents { true }
      children { 1 }
      outcome { 'full' }
      application_type { 'income' }
      decision_date { Time.zone.today }
      income_period { Application::INCOME_PERIOD[:last_month] }
    end

    factory :application_no_remission do
      applicant_factory { :applicant_with_all_details }
      fee { 410 }
      dependents { false }
      children { 1 }
      income { 3000 }
      outcome { 'none' }
      application_type { 'income' }
    end

    factory :single_applicant_under_66 do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:under_66] }
    end

    factory :single_applicant_over_66 do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:over_66] }
    end

    factory :married_applicant_over_66 do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married, :over_66] }
    end

    factory :applicant_under_66, aliases: [:married_applicant_under_66] do
      applicant_factory { :applicant_with_all_details }
      applicant_traits { [:married, :under_66] }
    end

    trait :partner_over_66 do
      partner_over_66 { true }
    end

    after(:build) do |application, evaluator|
      build_related_for_application(scope: self, method: :build, application: application, evaluator: evaluator, stub: false)
    end

    after(:stub) do |application, evaluator|
      around_stub(application) do
        build_related_for_application(scope: self, method: :build_stubbed, application: application, evaluator: evaluator, stub: true)
      end
    end
  end
end
