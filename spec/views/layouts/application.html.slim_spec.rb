require 'rails_helper'

RSpec.describe "layouts/application.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)          { create :user }
  let(:admin_user)    { create :admin_user }

  context 'logged out user' do
    it 'will see a log in link' do
      render
      expect(rendered).to include('Sign in')
    end
  end
end
