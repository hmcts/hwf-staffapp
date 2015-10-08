require 'rails_helper'

RSpec.describe EvidenceController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/evidence/1').to route_to('evidence#show', id: '1')
    end

    it 'routes to #evidence_accuracy' do
      expect(get: '/evidence/1/accuracy').to route_to('evidence#accuracy', id: '1')
    end

    it 'routes to #evidence_accuracy_save' do
      expect(post: '/evidence/1/accuracy_save').to route_to('evidence#accuracy_save', id: '1')
    end

    it 'routes to #evidence_income' do
      expect(get: '/evidence/1/income').to route_to('evidence#income', id: '1')
    end

    it 'routes to #evidence_accuracy_save' do
      expect(post: '/evidence/1/income_save').to route_to('evidence#income_save', id: '1')
    end
  end
end
