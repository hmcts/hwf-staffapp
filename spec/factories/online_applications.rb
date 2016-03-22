FactoryGirl.define do
  factory :online_application do
    married false
    threshold_exceeded false
    benefits true
    children 0
    refund false
    probate false
    ni_number 'AB123456C'
    date_of_birth Time.zone.parse('10/03/1976')
    first_name 'Peter'
    last_name 'Smith'
    address '102 Petty France, London'
    postcode 'SW1H 9AJ'
    email_contact false
    phone_contact false
    post_contact false
    feedback_opt_in true

    factory :online_application_with_all_details do
      children 2
      refund true
      date_fee_paid Time.zone.now - 2.months
      probate true
      deceased_name 'Some Deceased'
      date_of_death Time.zone.now - 3.months
      case_number '234567'
      form_name 'FGDH122'
      email_contact true
      email_address 'peter.smith@example.com'
      phone_contact true
      phone '2345678'
      post_contact true
    end

    trait :with_reference do
      sequence(:reference) { |n| "HWF-#{n}" }
    end

    trait :completed do
      fee 450
      jurisdiction
      emergency_reason 'EMERGENCY'
    end
  end
end
