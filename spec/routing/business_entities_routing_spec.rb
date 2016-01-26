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

    it 'routes to #deactivate' do
      expect(get: '/offices/1/business_entities/1/deactivate').to route_to('business_entities#deactivate', office_id: '1', id: '1')
    end

    it 'routes to #confirm_deactivate' do
      expect(post: '/offices/1/business_entities/1/confirm_deactivate').to route_to('business_entities#confirm_deactivate', office_id: '1', id: '1')
    end
  end
end
