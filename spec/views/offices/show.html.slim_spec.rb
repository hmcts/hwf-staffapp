require 'rails_helper'

RSpec.describe "offices/show", type: :view do

  shared_examples 'an elevated user' do
    it 'renders name attribute' do
      expect(rendered).to match(/New office name/)
    end
  end

  include Devise::TestHelpers

  let(:manager) { create(:manager) }
  let(:admin)   { create(:admin_user) }

  before(:each) do
    @office = assign(:office, create(:office, name: 'New office name'))
  end

  context 'as a manager' do
    before(:each) do
      sign_in manager
      render
    end

    it_behaves_like 'an elevated user'

    it 'does not render a link to the list' do
      expect(rendered).not_to have_xpath("//a[@href='#{offices_path}']")
    end
  end

  context 'as an admin' do
    before(:each) do
      sign_in admin
      render
    end

    it_behaves_like 'an elevated user'

    it 'renders a link to the list' do
      expect(rendered).to have_xpath("//a[@href='#{offices_path}']")
    end
  end
end
