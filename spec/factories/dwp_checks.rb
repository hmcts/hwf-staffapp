FactoryGirl.define do
  factory :dwp_check do
    last_name "Smith"
    dob Date.today - 20.years
    ni_number "AB123456C"
    date_to_check Date.yesterday
    checked_by nil
    laa_code nil
    unique_number nil
    our_api_token 'name@20150101.ab12-cd34'
    association :office
  end
end
