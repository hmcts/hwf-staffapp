require 'rails_helper'

RSpec.describe 'shared/_footer', type: :view do
  let(:user) { create :user }

  context 'a signed out user' do
    before { render }

    it 'is shown the feedback email address' do
      expect(rendered).to have_xpath("//a[contains(@href,'mailto:#{Settings.mail.feedback}')]")
    end
  end

  context 'a signed in user' do
    before do
      sign_in user
      render
    end

    it 'has a link to the feedback form' do
      expect(rendered).to have_xpath("//a[contains(@href,'#{feedback_path}')]")
    end
  end
end
