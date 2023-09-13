require 'rails_helper'

RSpec.describe HealthStatusController do
  describe 'routing' do
    it 'routes to #healthcheck' do
      expect(get: '/health', format: :json).to route_to('health_status#show', format: 'json')
    end

    it 'readiness routes to #healthcheck' do
      expect(get: '/health/readiness', format: :json).to route_to('health_status#show', format: 'json')
    end

    it 'liveness routes to #healthcheck' do
      expect(get: '/health/liveness', format: :json).to route_to('health_status#show', format: 'json')
    end
  end
end
