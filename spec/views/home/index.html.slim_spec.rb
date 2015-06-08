require 'rails_helper'

RSpec.describe "home/index.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)          { create :user }

  it 'contain our dashboard header' do
    sign_in user
    render
    expect(rendered).to include('eligible for benefits-based remission')
  end
end
