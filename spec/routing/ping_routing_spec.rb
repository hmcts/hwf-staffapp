require 'rails_helper'

RSpec.describe PingController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/ping', format: :json).to route_to('ping#index')
    end
  end
end
