FactoryBot.define do
  factory :hmrc_check do
    address { { address: { line1: Faker::Address.street_address } } }
    employment { { startDate: Faker::Date.in_date_period.to_fs(:db), endDate: Faker::Date.in_date_period.to_fs(:db) } }
    income { { taxReturns: [{ taxYear: "2018-19", summary: [{ totalIncome: Faker::Number.decimal(l_digits: 2) }] }] } }
    tax_credit {
      { child: nil,
        work:
      [{ "payProfCalcDate" => "2020-08-18",
         "totalEntitlement" => Faker::Number.decimal(l_digits: 2),
         "workingTaxCredit" => { "amount" => Faker::Number.decimal(l_digits: 2), "paidYTD" => Faker::Number.decimal(l_digits: 2) },
         "payments" => [{ "startDate" => Faker::Date.in_date_period.to_fs(:db), "endDate" => Faker::Date.in_date_period.to_fs(:db), "frequency" => 28, "tcType" => "ETC", "amount" => Faker::Number.decimal(l_digits: 2) }] }] }
    }
    evidence_check
    ni_number { 'SN789456C' }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65).to_fs(:db) }
    request_params { { date_range: { from: "1/2/2021", to: "28/2/2021" } } }
    user

    trait :applicant do
      check_type { 'applicant' }
    end

    trait :partner do
      check_type { 'partner' }
    end
  end
end
