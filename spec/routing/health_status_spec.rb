require 'rails_helper'

RSpec.describe HealthStatusController, type: :routing do
  describe 'routing' do
    it 'routes to #ping' do
      expect(get: '/ping', format: :json).to route_to('health_status#ping')
    end
  end
end
