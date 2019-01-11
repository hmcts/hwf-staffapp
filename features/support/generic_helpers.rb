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

def new_password_page
  @new_password_page ||= NewPasswordPage.new
end
