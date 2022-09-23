FactoryBot.define do

  factory :audit_personal_data_purge do
    application_reference_number { generate(:reference_number) }
    purged_date { Time.zone.today }
  end
end
