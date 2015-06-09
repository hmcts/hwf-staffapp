FactoryGirl.define do

  sequence(:name)     { |n| "Office no. #{n}" }

  factory :office do
    name
    factory :invalid_office do
      name nil
    end
  end

end
