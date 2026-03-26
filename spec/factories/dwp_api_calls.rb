FactoryBot.define do
  factory :dwp_api_call do
    benefit_check
    endpoint_name { 'match_citizen' }
    response_status { 200 }
    request_params { { last_name: 'SMITH', date_of_birth: '1985-06-15', nino_fragment: '9012' } }
    data { { 'data' => { 'id' => 'abc-123-guid' } } }
  end
end
