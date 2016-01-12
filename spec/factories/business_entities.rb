FactoryGirl.define do
  factory :business_entity do
    office
    jurisdiction
    code { 'SD123' }
    name { 'Special division' }
    valid_from Time.zone.today
  end
end
