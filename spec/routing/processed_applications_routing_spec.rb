require 'rails_helper'

RSpec.describe ProcessedApplicationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/processed_applications').to route_to('processed_applications#index')
    end

    it 'routes to #show' do
      expect(get: '/processed_applications/1').to route_to('processed_applications#show', id: '1')
    end
  end
end
