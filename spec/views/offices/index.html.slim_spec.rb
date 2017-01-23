require 'rails_helper'

RSpec.describe "offices/index", type: :view do
  subject { rendered }

  let(:offices) { create_list(:office, 2) }

  let(:office_new?) { false }

  before do
    assign(:offices, offices)
    allow(view).to receive(:policy).with(:office).and_return(instance_double(OfficePolicy, new?: office_new?))
    allow(view).to receive(:policy).with(offices[0]).and_return(instance_double(OfficePolicy, edit?: true))
    allow(view).to receive(:policy).with(offices[1]).and_return(instance_double(OfficePolicy, edit?: false))

    render
  end

  describe 'Link to change office details' do
    context 'when user has permission to change the office\'s details' do
      it 'is rendered' do
        is_expected.to have_xpath('//tbody/tr[1]/td[3]/a')
      end
    end

    context 'when user does not have permission to chang the office\'s details' do
      it 'is not rendered' do
        is_expected.not_to have_xpath('//tbody/tr[2]/td[3]/a')
      end
    end
  end

  describe 'The link to create office' do
    context 'when user has permission to create new office' do
      let(:office_new?) { true }

      it 'is rendered' do
        expect(rendered).to have_link('New Office')
      end
    end

    context 'when user does not have permission to create new office' do
      it 'is not rendered' do
        expect(rendered).not_to have_link('New Office')
      end
    end
  end
end
