FactoryGirl.define do

  sequence(:name) { |n| "#{Faker::Company.name} #{n}" }

  factory :office do
    name
    factory :invalid_office do
      name nil
    end
  end

end
