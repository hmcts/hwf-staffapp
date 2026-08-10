require 'rails_helper'

RSpec.feature 'Appeals letter templates page' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }

  before do
    login_as(user)
    visit appeals_letter_templates_path
  end

  scenario 'displays the page heading' do
    expect(page).to have_text('Appeals letter templates')
  end

  scenario 'displays a heading for each letter template' do
    headings = [
      'Stage 1 HwF Appeal – On Issue Fee – Appeal Refused',
      'Stage 1 HwF Appeal – Refund Fee – Appeal Refused',
      'Stage 1 HwF Appeal – On Issue Fee – Appeal Upheld/Partially Upheld',
      'Stage 1 HwF Appeal – Refund Fee – Appeal Upheld/Partially Upheld',
      'Stage 2 HwF Appeal – On Issue Fee – Appeal Refused',
      'Stage 2 HwF Appeal – Refund Fee – Appeal Refused',
      'Stage 2 HwF Appeal – On Issue Fee – Appeal Upheld/Partially Upheld',
      'Stage 2 HwF Appeal – Refund Fee – Appeal Upheld/Partially Upheld'
    ]

    headings.each do |heading|
      expect(page).to have_css('h2', text: heading)
    end
  end

  scenario 'displays the review instructions' do
    expect(page).to have_text('You must review the letter templates carefully')
  end
end
