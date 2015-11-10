module FeatureHelpers
  def start_new_application
    visit '/'
    click_link 'Start now'
  end
end

RSpec.configure do |c|
  c.include FeatureHelpers, type: :feature
end
