FactoryGirl.define do
  factory :business_entity do
    office
    jurisdiction
    be_code { 'SD123' }
    sequence(:sop_code) { |n| n.to_s.rjust(9, '0') }
    name { 'Special division' }
    valid_from Time.zone.today
  end
end
