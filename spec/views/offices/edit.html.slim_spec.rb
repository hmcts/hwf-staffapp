require 'rails_helper'

RSpec.describe 'offices/edit', type: :view do

  include Devise::TestHelpers

  let(:manager)       { create(:manager) }
  let(:admin)         { create(:admin_user) }
  let!(:office)        { assign(:office, create(:office)) }
  let!(:jurisdictions) { assign(:jurisdictions, office.jurisdictions) }
  let!(:becs) { assign(:becs, office.business_entities) }

  before do
    allow(view).to receive(:policy).with(:business_entity).and_return(double(index?: true))
  end

  shared_examples 'an elevated user' do
    it 'renders form and jurisdiction list' do
      expect(rendered).to have_xpath('//input[@name="office[jurisdiction_ids][]"]', count: jurisdictions.count + 1)

      assert_select 'form[action=?][method=?]', office_path(office), 'post' do
        assert_select 'input#office_name[name=?]', 'office[name]'
      end
    end
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
