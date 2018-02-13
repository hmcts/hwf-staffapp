require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :routing do
  describe 'routing' do
    it 'routes to #personal_information' do
      expect(get: '/applications/1/personal_informations').to route_to('applications/process/personal_informations#index', application_id: '1')
    end

    it 'routes to #personal_information#create' do
      expect(post: '/applications/1/personal_informations').to route_to('applications/process/personal_informations#create', application_id: '1')
    end

    it 'routes to #application_details' do
      expect(get: '/applications/1/details').to route_to('applications/process/details#index', application_id: '1')
    end

    it 'routes to #application_details_save' do
      expect(post: '/applications/1/details').to route_to('applications/process/details#create', application_id: '1')
    end

    it 'routes to #savings_investments' do
      expect(get: '/applications/1/savings_investments').to route_to('applications/process/savings_investments#index', application_id: '1')
    end

    it 'routes to #savings_investments_save' do
      expect(post: '/applications/1/savings_investments').to route_to('applications/process/savings_investments#create', application_id: '1')
    end

    it 'routes to #benefits' do
      expect(get: '/applications/1/benefits').to route_to('applications/process/benefits#index', application_id: '1')
    end

    it 'routes to #benefits_save' do
      expect(post: '/applications/1/benefits').to route_to('applications/process/benefits#create', application_id: '1')
    end

    it 'routes to #income' do
      expect(get: '/applications/1/incomes').to route_to('applications/process/incomes#index', application_id: '1')
    end

    it 'routes to #income_save' do
      expect(post: '/applications/1/incomes').to route_to('applications/process/incomes#create', application_id: '1')
    end

    it 'routes to #income_result' do
      expect(get: '/applications/1/income_result').to route_to('applications/process#income_result', application_id: '1')
    end
  end
end
