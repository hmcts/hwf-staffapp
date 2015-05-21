require 'rails_helper'

RSpec.describe FeedbackController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/feedback/display').to route_to('feedback#index')
    end

    it 'routes to #new' do
      expect(get: '/feedback/').to route_to('feedback#new')
    end
  end
end
