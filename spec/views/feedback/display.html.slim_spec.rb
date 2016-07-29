require 'rails_helper'

RSpec.describe 'feedback/index', type: :view do
  let(:admin) { create :admin_user }

  before do
    assign(:feedback, create_list(:feedback, 2, user: admin, office: admin.office))
    sign_in admin
    render
  end

  it 'identifys the user' do
    expect(rendered).to have_xpath("//td[contains(., '#{admin.name}')]")
  end

  it 'provides the users email' do
    expect(rendered).to have_xpath("//a[@href='mailto:#{admin.email}']")
  end

end
