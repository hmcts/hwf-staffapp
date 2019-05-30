FactoryGirl.define do
  factory :feedback do
    experience nil
    ideas nil
    rating nil
    help nil
    user
    office
  end
end
