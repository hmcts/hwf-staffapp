
def dwp_api_response(response, status = 200)
  json = { "original_client_ref": "unique",
           "benefit_checker_status": "#{response}",
           "confirmation_ref": "T1426267181940",
           "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check" }.to_json
  stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
    to_return(status: status, body: json, headers: {})
end
