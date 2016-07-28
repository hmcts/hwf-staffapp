RSpec.configure do |c|
  c.include Devise::Test::ControllerHelpers, type: :controller
  c.include Devise::Test::ControllerHelpers, type: :view
end
