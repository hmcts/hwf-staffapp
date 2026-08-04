require 'rails_helper'

RSpec.feature 'LCEP letter templates page' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let(:user) { create(:user) }

  before do
    login_as(user)
    visit lcep_letter_templates_path
  end

  scenario 'displays the page heading' do
    expect(page).to have_text("Lord Chancellor's Exceptional Power letter templates")
  end

  scenario 'displays a heading for each letter template' do
    headings = [
      'Initial information letter advising about the LCEP',
      'Stage 1 Request LCEP – Upheld/Partially Upheld',
      'Stage 1 Request LCEP - Refused',
      'Stage 2 Request LCEP – Upheld/Partially Upheld',
      'Stage 2 Request LCEP - Refused'
    ]

    headings.each do |heading|
      expect(page).to have_css('h2', text: heading)
    end
  end

  scenario 'displays the review instructions' do
    expect(page).to have_text('You must review the letter templates carefully')
  end
end
