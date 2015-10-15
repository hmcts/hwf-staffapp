require 'rails_helper'

RSpec.describe PaymentsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/payments/1').to route_to('payments#show', id: '1')
    end
  end
end
