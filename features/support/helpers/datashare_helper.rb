def stub_hmrc_api
  hmrc_api = instance_double(HwfHmrcApi::Connection)
  allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
  allow(hmrc_api).to receive(:match_user)
  allow(hmrc_api).to receive(:child_tax_credits).and_return([])
  allow(hmrc_api).to receive(:working_tax_credits).and_return([])
  authentication = instance_double(HwfHmrcApi::Authentication, access_token: 1, expires_in: 1)
  allow(hmrc_api).to receive(:authentication).and_return(authentication)
  hmrc_api
end

def hmrc_low_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({'income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 500 } }]})
end

def hmrc_medium_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({'income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 1200 } }]})
end

def hmrc_high_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({'income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 7000 } }]})
end

def hmrc_working_tax_credits
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({'income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 2000 } }]})
  allow(hmrc_api).to receive(:working_tax_credits).and_return([{ "awards" => ['work test'] }])
end

def hmrc_child_tax_credits
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({'income' => [{ "grossEarningsForNics" => { "inPayPeriod1" => 1900 } }]})
  allow(hmrc_api).to receive(:child_tax_credits).and_return([{ "awards" => ['child test'] }])
end
