FactoryGirl.define do

  sequence(:name) { |n| "#{Faker::Company.name} #{n}" }

  factory :office do
    name
    factory :invalid_office do
      name nil
    end
    sequence(:entity_code) { |n| "#{Faker::Commerce.color.split('').sample(2).join.upcase}#{n.to_s.ljust(3, '0')}" }

    factory :office_with_jurisdictions do
      transient do
        jurisdictions_count { 2 }
      end

      after(:create) do |office, evaluator|
        create_list :office_jurisdiction, evaluator.jurisdictions_count, office: office
      end
    end
  end
end
