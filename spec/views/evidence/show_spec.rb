require 'rails_helper'

RSpec.describe 'evidence/show', type: :view do

  before(:each) { render }

  it 'has the title' do
    expect(rendered).to have_content 'Waiting for evidence'
  end

  it 'has start block' do
    expect(rendered).to have_content 'Process evidence'
  end

  it 'has "Processing details" section' do
    expect(rendered).to have_content 'Processing details'
  end
end
