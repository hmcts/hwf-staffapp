FactoryGirl.define do
  factory :applicant do
    transient do
      application nil
    end

    factory :applicant_with_all_details do
      title { Faker::Name.prefix }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth Time.zone.today - 20.years
      ni_number nil
      married false
    end

    trait :married do
      married true
    end

    trait :under_61 do
      date_of_birth Time.zone.today - 60.years
    end

    trait :over_61 do
      date_of_birth Time.zone.today - 65.years
    end

    after(:build) do |applicant, evaluator|
      app = evaluator.application
      applicant.application = app.present? ? app : build(:application, applicant: applicant)
    end
  end
end
