require 'rails_helper'

RSpec.describe BusinessEntitiesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/offices/1/business_entities').to route_to('business_entities#index', office_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/offices/1/business_entities/new').to route_to('business_entities#new', office_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/offices/1/business_entities').to route_to('business_entities#create', office_id: '1')
    end
  end
end
