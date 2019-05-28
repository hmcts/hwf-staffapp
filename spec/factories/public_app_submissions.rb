FactoryBot.define do
  factory :public_app_submission, class: OpenStruct do

    to_create { |instance| instance.as_json['table'] }

    married { true }
    min_threshold_exceeded { true }
    max_threshold_exceeded { false }
    over_61 { false }
    amount { 3500 }
    benefits { true }
    children { 0 }
    income { 100 }
    refund { false }
    probate { false }
    case_number { 'AB16D1234' }
    form_name { 'O113' }
    ni_number { 'AB123456A' }
    date_of_birth { '1990-01-01' }
    title { 'Mr' }
    first_name { 'Foo' }
    last_name { 'Bar' }
    address { '1 The Street' }
    postcode { 'POS 0DE' }
    email_contact { false }
    phone_contact { true }
    phone { '000 000 0000' }
    post_contact { 'true' }
    feedback_opt_in { true }

    trait :et do
      form_name { 'ET1' }
      case_number { 'ET16/12345' }
    end

    trait :refund do
      refund { true }
      date_fee_paid { '2016-01-01' }
    end

    trait :probate_case do
      probate { true }
      deceased_name { 'foo' }
      date_of_death { '2016-01-01' }
    end

    trait :with_children do
      children { 1 }
    end

    trait :email_contact do
      email_contact { true }
      email_address { 'foo@bar.com' }
    end
  end
end
