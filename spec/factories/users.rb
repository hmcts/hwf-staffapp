FactoryGirl.define do
  factory :user do
    role 'user'
    sequence(:email)     { |n| "user_#{n}@digital.justice.gov.uk" }
    password 'password'
    name 'user'
    association :office
    factory :admin_user do
      role 'admin'
    end
    factory :manager do
      role 'manager'
    end
  end
end
