FactoryBot.define do
  factory :office do
    transient do
      jurisdictions_count { 2 }
    end

    sequence(:name) { |n| "#{Faker::Company.name.delete(',')} #{n}" }
    sequence(:entity_code) { |n| "#{Faker::Commerce.color.split('').sample(2).join.upcase}#{n.to_s.rjust(3, '0')}" }

    jurisdictions { build_list :jurisdiction, jurisdictions_count }

    factory :invalid_office do
      name { nil }
    end

    after(:create) do |office, _|
      office.jurisdictions.each do |jurisdiction|
        create(:business_entity, office: office, jurisdiction: jurisdiction)
      end
    end
  end
end
