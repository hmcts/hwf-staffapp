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

    trait :with_reference do
      sequence(:reference) { |n| "HWF-#{n}" }
    end
  end
end
