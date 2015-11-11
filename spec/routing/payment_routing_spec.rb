require 'rails_helper'

RSpec.describe PartPaymentsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/part_payments/1').to route_to('part_payments#show', id: '1')
    end

    it 'routes to #accuracy' do
      expect(get: '/part_payments/1/accuracy').to route_to('part_payments#accuracy', id: '1')
    end

    it 'routes to #accuracy_save' do
      expect(post: '/part_payments/1/accuracy_save').to route_to('part_payments#accuracy_save', id: '1')
    end

    it 'routes to #summary' do
      expect(get: '/part_payments/1/summary').to route_to('part_payments#summary', id: '1')
    end
  end
end
