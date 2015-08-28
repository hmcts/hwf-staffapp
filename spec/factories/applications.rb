FactoryGirl.define do
  factory :application do
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
    children 1
    income 500
    threshold_exceeded false

    factory :probate_application do
      probate true
      deceased_name 'John Smith'
      date_of_death Time.zone.yesterday
    end

    factory :refund_application do
      refund true
      date_fee_paid Time.zone.yesterday
    end

    factory :no_benefits do
      benefits false
    end

    factory :application_confirm do
      benefits false
      application_outcome 'full'
      application_type 'income'
    end
  end
end
