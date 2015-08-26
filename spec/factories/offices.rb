FactoryGirl.define do

  sequence(:name) { |n| "#{Faker::Company.name} #{n}" }

  factory :office do
    name
    factory :invalid_office do
      name nil
    end
    sequence(:entity_code) { |n| "#{Faker::Commerce.color.split('').sample(2).join.upcase}#{n.to_s.ljust(3, '0')}" }
  end
end
