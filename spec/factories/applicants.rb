FactoryGirl.define do
  factory :applicant do
    factory :applicant_with_all_details do
      title { Faker::Name.prefix }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth Time.zone.today - 20.years
      ni_number 'AB123456C'
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

    after(:build) do |applicant|
      applicant.application ||= build(:application, applicant: applicant)
    end

    after(:stub) do |applicant|
      around_stub(applicant) do
        applicant.application ||= build_stubbed(:application, applicant: applicant)
      end
    end
  end
end
