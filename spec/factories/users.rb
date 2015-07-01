FactoryGirl.define do
  factory :user do
    role 'user'
    sequence(:email)     { |n| "user_#{n}@digital.justice.gov.uk" }
    password 'password'
    name 'user'
    association :office
    association :jurisdiction
    factory :admin_user do
      role 'admin'
    end
    factory :manager do
      role 'manager'
    end
    factory :invalid_user do
      email nil
      name nil
    end
  end
end
