FactoryGirl.define do
  factory :user do
    role 'user'
    sequence(:email)     { |n| "user_#{n}@digital.justice.gov.uk" }
    password 'password'
    name 'user'
    factory :admin_user do
      role 'admin'
    end
  end
end
