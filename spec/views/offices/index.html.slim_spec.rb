require 'rails_helper'

RSpec.describe "offices/index", type: :view do
  include Devise::TestHelpers

  let(:admin_user)    { FactoryGirl.create :admin_user }
  before(:each) do
    assign(:offices, [
      Office.create!(
        :name => "Name"
      ),
      Office.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of offices" do
    sign_in admin_user
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
