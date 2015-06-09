FactoryGirl.define do
  factory :r2_calculator do
    fee 9.99
    married true
    children 1
    income '9.99'
    association :created_by, factory: 'user'
    remittance 4.44
    to_pay 5.55

    factory :invalid_calculator do
      fee 'invalid'
    end
  end
end
