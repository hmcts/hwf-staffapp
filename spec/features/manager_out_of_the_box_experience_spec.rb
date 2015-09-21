require 'rails_helper'

RSpec.feature 'Manager has to setup their office and preferences', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:manager) { create :manager, office: office, sign_in_count: sign_in_count }

  before do
    login_as(manager)
    visit root_path
  end

  context 'Manager logging in for the first time' do
    let(:sign_in_count) { 0 }
  end

  context 'Manager logging in for second time or later' do
    let(:sign_in_count) { 1 }

    context 'when the office is already setup' do
      let(:office) { create :office_with_jurisdictions }

      scenario 'the dashboard is displayed' do
        expect(page.current_path).to eql '/'
      end
    end

    context 'when the office is not setup' do
      scenario 'the office setup page is displayed' do
        expect(page.current_path).to eql "/offices/#{office.id}/edit"
      end
    end
  end
end
