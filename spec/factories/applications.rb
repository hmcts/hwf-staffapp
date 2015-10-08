FactoryGirl.define do
  factory :application do
    sequence(:reference) { |n| "AB001-#{Time.zone.now.strftime('%y')}-#{n}" }
    title { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth Time.zone.today - 20.years
    ni_number nil
    married false
    fee '310.00'
    association :jurisdiction
    date_received Time.zone.today
    benefits true
    dependents true
    children 1
    income 500
    threshold_exceeded false
    refund false
    user

    trait :probate do
      probate true
      deceased_name 'John Smith'
      date_of_death Time.zone.yesterday
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
      fee 410
      benefits false
      income 2000
      dependents true
      children 3
      married true
    end

    factory :application_full_remission do
      fee 410
      benefits false
      income 10
      dependents true
      children 1
      married true
    end

    factory :application_no_remission do
      fee 410
      married false
      dependents false
      children 1
      income 3000
    end

    factory :applicant_under_61 do
      married true
      date_of_birth Time.zone.today - 60.years
    end

    factory :married_applicant_under_61 do
      married true
      date_of_birth Time.zone.today - 60.years
    end

    factory :married_applicant_over_61 do
      married true
      date_of_birth Time.zone.today - 65.years
    end
  end
end
