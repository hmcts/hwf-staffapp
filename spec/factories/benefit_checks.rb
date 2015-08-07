FactoryGirl.define do
  factory :benefit_check do
    last_name "Smith"
    date_of_birth Time.zone.today - 20.years
    ni_number "AB123456C"
    date_to_check Time.zone.yesterday
    our_api_token 'name@20150101.ab12-cd34'

    factory :invalid_benefit_check do
      last_name nil
    end
  end
end
