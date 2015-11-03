require 'rails_helper'

RSpec.describe ProcessedApplicationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/processed_applications').to route_to('processed_applications#index')
    end
  end
end
