include Warden::Test::Helpers
Warden.test_mode!

def wait_for
  Timeout.timeout(Capybara.default_max_wait_time) do
    begin
      loop until yield
    rescue # rubocop:disable Lint/HandleExceptions
      # ignored
    end
  end
end

def wait_for_document_ready
  wait_for { page.evaluate_script('document.readyState').eql? 'complete' }
end

def scroll_to_bottom
  WaitUntil.wait_until(3, 'Failed as browser hasnt reached bottom of window') do
    page.execute_script 'window.scrollTo(0,$(document).height())'
    y_position = page.evaluate_script 'window.scrollY'
    browser_height = page.evaluate_script '$(window).height();'
    doc_height = page.evaluate_script '$(document).height();'
    (y_position + browser_height).eql?(doc_height)
  end
end

module WaitUntil
  def self.wait_until(timeout = 10, message = nil, &block)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout, message: message)
    wait.until(&block)
  end
end

def base_page
  @base_page ||= BasePage.new
end

def sign_in_page
  @sign_in_page ||= SignInPage.new
end

def user_dashboard_page
  @user_dashboard_page ||= UserDashboardPage.new
end

def admin_dashboard_page
  @admin_dashboard_page ||= AdminDashboardPage.new
end

def user
  @user ||= FactoryGirl.build(:applicant, application: application)
end

def admin_user
  @admin_user ||= FactoryGirl.build(:applicant, application: application)
end

# def user_signed_in
#   office = FactoryGirl.create(:office)
#   user = FactoryGirl.create(:user, office: office)
#   manager = FactoryGirl.create(:manager, office: office)
#   business_entity = office.business_entities.first
#   login_as user
#   sign_in_page.load_page 
# end

# def admin_signed_in
#   office = FactoryGirl.create(:office)
#   admin = FactoryGirl.create(:admin_user, office: office)
#   manager = FactoryGirl.create(:manager, office: office)
#   business_entity = office.business_entities.first
#   login_as admin
#   sign_in_page.load_page
# end
