require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :routing do
  describe 'routing' do
    it 'routes to #personal_information' do
      expect(get: '/applications/1/personal_information').to route_to('applications/process#personal_information', application_id: '1')
    end

    it 'routes to #personal_information' do
      expect(put: '/applications/1/personal_information').to route_to('applications/process#personal_information_save', application_id: '1')
    end

    it 'routes to #application_details' do
      expect(get: '/applications/1/application_details').to route_to('applications/process#application_details', application_id: '1')
    end

    it 'routes to #application_details' do
      expect(put: '/applications/1/application_details').to route_to('applications/process#application_details_save', application_id: '1')
    end

    it 'routes to #savings_investments' do
      expect(get: '/applications/1/savings_investments').to route_to('applications/process#savings_investments', application_id: '1')
    end

    it 'routes to #savings_investments_save' do
      expect(put: '/applications/1/savings_investments').to route_to('applications/process#savings_investments_save', application_id: '1')
    end

    it 'routes to #benefits' do
      expect(get: '/applications/1/benefits').to route_to('applications/process#benefits', application_id: '1')
    end

    it 'routes to #benefits_save' do
      expect(put: '/applications/1/benefits').to route_to('applications/process#benefits_save', application_id: '1')
    end

    it 'routes to #benefits_result' do
      expect(get: '/applications/1/benefits_result').to route_to('applications/process#benefits_result', application_id: '1')
    end

    it 'routes to #income' do
      expect(get: '/applications/1/income').to route_to('applications/process#income', application_id: '1')
    end

    it 'routes to #income_save' do
      expect(put: '/applications/1/income').to route_to('applications/process#income_save', application_id: '1')
    end

    it 'routes to #income_result' do
      expect(get: '/applications/1/income_result').to route_to('applications/process#income_result', application_id: '1')
    end
  end
end
