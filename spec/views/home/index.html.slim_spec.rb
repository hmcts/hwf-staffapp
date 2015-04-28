require 'rails_helper'

RSpec.describe "home/index.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }

  it 'contain our dashboard header' do
    sign_in user
    render
    expect(rendered).to include('dashboard')
  end
end
