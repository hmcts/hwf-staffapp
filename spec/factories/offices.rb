FactoryGirl.define do

  sequence(:name)     { |n| "Office no. #{n}" }

  factory :office do
    name
  end

end
