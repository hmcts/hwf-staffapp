require 'rails_helper'

RSpec.describe Api::SubmissionsController do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: 'api/submissions').to route_to('api/submissions#create')
    end
  end
end
