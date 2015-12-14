FactoryGirl.define do
  factory :business_entity do
    office
    jurisdiction
    code { 'SD123' }
    name { 'Special division' }
  end
end
