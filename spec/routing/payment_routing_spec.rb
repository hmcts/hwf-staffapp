require 'rails_helper'

RSpec.describe PaymentsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/payments/1').to route_to('payments#show', id: '1')
    end

    it 'routes to #accuracy' do
      expect(get: '/payments/1/accuracy').to route_to('payments#accuracy', id: '1')
    end

    it 'routes to #accuracy_save' do
      expect(post: '/payments/1/accuracy_save').to route_to('payments#accuracy_save', id: '1')
    end

    it 'routes to #summary' do
      expect(get: '/payments/1/summary').to route_to('payments#summary', id: '1')
    end
  end
end
