module DatashareHelper

  context 'low income' do
    before {
      hmrc_check.income = [{ "grossEarningsForNics" => { "inPayPeriod1" => 10000 } }]
      hmrc_check.additional_income = 0
      hmrc_check.save
    }

    context 'medium income' do
      before {
        hmrc_check.income = [{ "grossEarningsForNics" => { "inPayPeriod1" => 24000 } }]
        hmrc_check.additional_income = 0
        hmrc_check.save
      }

      context 'higher income' do
        before {
          hmrc_check.income = [{ "grossEarningsForNics" => { "inPayPeriod1" => 70000 } }]
          hmrc_check.additional_income = 0
          hmrc_check.save
        }

        context 'work_tax_credit_income' do
          before {
            work_income = [
              { payProfCalcDate: "2021-12-01",
                totalEntitlement: 1000,
                workingTaxCredit: {
                  amount: 930.98,
                  paidYTD: 8976.34
                },
                "payments" => [
                  { "startDate" => "2021-10-01", "endDate" => "2021-10-31", "frequency" => 7, "tcType" => "ICC", "amount" => 86.34 },
                  { "startDate" => "2021-11-01", "endDate" => "2021-11-30", "frequency" => 7, "tcType" => "ICC", "amount" => 56.24 }
                ] },
            ]

            hmrc_check.tax_credit = { child: nil, work: work_income }
            hmrc_check.save
          }

        end

        def low_income(hmrc_api)
          allow(hmrc_api).to receive(:paye).and_return('low income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 10000 } }])
        end

        def medium_income(hmrc_api)
          allow(hmrc_api).to receive(:paye).and_return('medium income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 24000 } }])
        end

        def higher_income(hmrc_api)
          allow(hmrc_api).to receive(:paye).and_return('higher income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 70000 } }])
        end

        def working_tax_credit(hmrc_api)
          allow(hmrc_api).to receive(:tax_credit).and_return('work_tax_credit_income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 70000 } }])
        end


      end
    end
  end
end
