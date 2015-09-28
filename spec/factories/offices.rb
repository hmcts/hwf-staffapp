FactoryGirl.define do
  factory :office do
    transient do
      jurisdictions_count { 2 }
    end

    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    sequence(:entity_code) { |n| "#{Faker::Commerce.color.split('').sample(2).join.upcase}#{n.to_s.ljust(3, '0')}" }

    jurisdictions { build_list :jurisdiction, jurisdictions_count }

    factory :invalid_office do
      name nil
    end
  end
end
