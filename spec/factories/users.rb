FactoryGirl.define do
  factory :user, aliases: [:staff] do
    role 'user'
    sequence(:email) { |n| "user_#{n}@digital.justice.gov.uk" }
    password 'password'
    name 'user'
    association :office
    association :jurisdiction
    factory :admin_user, aliases: [:admin] do
      role 'admin'
    end
    factory :manager do
      role 'manager'
    end
    factory :mi do
      role 'mi'
    end
    factory :invalid_user do
      email nil
      name nil
    end
    factory :deleted_user do
      deleted_at Time.zone.yesterday
    end
    factory :inactive_user do
      current_sign_in_at 4.months.ago
    end
    factory :active_user do
      current_sign_in_at 1.month.ago
    end
  end
end
