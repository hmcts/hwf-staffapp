FactoryGirl.define do
  factory :reference do
    application nil
    sequence(:reference) { |n| "AB001-#{Time.zone.now.strftime('%y')}-#{n}" }
  end
end
