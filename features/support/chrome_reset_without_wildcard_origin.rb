require 'capybara/selenium/driver'

# Chrome 158 rejects origin '*' in Capybara's session reset - see CHANGELOG.md
module ChromeResetWithoutWildcardOrigin
  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcardOrigin)
