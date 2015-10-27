require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :routing do
  describe 'routing' do
    it 'routes to #personal_information' do
      expect(get: '/applications/1/personal_information').to route_to('applications/process#personal_information', application_id: '1')
    end

    it 'routes to #personal_information' do
      expect(put: '/applications/1/personal_information').to route_to('applications/process#personal_information_save', application_id: '1')
    end
  end
end
