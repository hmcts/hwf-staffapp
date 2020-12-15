FactoryBot.define do
  factory :feedback do
    experience { nil }
    ideas { nil }
    rating { 4 }
    help { nil }
    user
    office
  end
end
