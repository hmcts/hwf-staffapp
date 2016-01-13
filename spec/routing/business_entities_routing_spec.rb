require 'rails_helper'

RSpec.describe BusinessEntitiesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/offices/1/business_entities').to route_to('business_entities#index', office_id: '1')
    end
  end
end
