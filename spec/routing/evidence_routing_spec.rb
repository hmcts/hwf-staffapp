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

    it 'routes to #evidence_income_save' do
      expect(post: '/evidence/1/income_save').to route_to('evidence#income_save', id: '1')
    end

    it 'routes to #evidence_result' do
      expect(get: '/evidence/1/result').to route_to('evidence#result', id: '1')
    end

    it 'routes to #evidence_summary' do
      expect(get: '/evidence/1/summary').to route_to('evidence#summary', id: '1')
    end

    it 'routes to #evidence_confirmation' do
      expect(get: '/evidence/1/confirmation').to route_to('evidence#confirmation', id: '1')
    end

    it 'route_to to #return_letter' do
      expect(get: '/evidence/1/return_letter').to route_to('evidence#return_letter', id: '1')
    end

    it 'route_to to #return_application' do
      expect(post: '/evidence/1/return_application').to route_to('evidence#return_application', id: '1')
    end
  end
end
