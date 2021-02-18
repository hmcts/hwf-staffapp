# Automated testing

## Dependencies

You need to install:

Ruby

[Bundler](http://bundler.io/)

[PhantomJS](https://github.com/teampoltergeist/poltergeist#installing-phantomjs)

To install all of the required gems:

$ bundle install

### Rubocop

To assess Ruby code quality across the application we use:

[Rubocop](https://github.com/bbatsov/rubocop)

To run the tool, use:

$ rubocop

### Running Cucumber scenarios

For UI feature testing, we use:

[Cucumber](http://cukes.info/)

[Capybara](https://github.com/jnicklas/capybara)

To run the standard Cucumber test suite, use:

$ bundle exec cucumber features 

To run the all scenarios in a particular feature file:

$ bundle exec cucumber features/landing_page.feature  

To run a particular scenario using line number:

$ bundle exec cucumber features/landing_page.feature:10 

To run in a browser:

$ DRIVER=chrome cucumber

$ DRIVER=firefox cucumber
Please note: Firefox with macOS 10.15 “Catalina”, please refer to [macOS notarization](https://firefox-source-docs.mozilla.org/testing/geckodriver/Notarization.html)

### Running cross browser and device tests using Sauce Labs

Replace 'SAUCE_USERNAME' and 'SAUCE_ACCESS_KEY' in hwf-staffapp/.env.test with your account details

Run tunnel:
Go to your Terminal

Go to the path where you've downloaded Sauce connect folder
Example: cd Downloads/sc-4.6.2-osx 

Run below command 
$ bin/sc -u <SAUCE_USERNAME> -k <SAUCE_ACCESS_KEY> --se-port 4449

Replace <SAUCE_USERNAME> and <SAUCE_ACCESS_KEY> with your account details

Wait for 'Sauce Connect is up, you may start your tests.'

[Add the tag '@saucelabs' to a scenario/s that you want to run.]

To run Sauce Labs feature using a specific browser:
$ DRIVER=saucelabs SAUCELABS_BROWSER=chrome_win_latest cucumber --tags @saucelabs

To run Sauce Labs feature on all devices and browsers:
$ bin/run_saucelabs

### Screenshots and HTML

To open screenshot or html:

$ open ./screenshot_cucumber_Start-now_2017-04-24-11-40-28.186.png

$ open ./screenshot_cucumber_Start-now_2017-04-24-11-40-28.186.html

### Creating an HTML report

Creating an HTML report uses the report_builder gem so ensure that you have done a bundle install before continuing.

To create a HTML report detailing the results of a cucumber test:

Run the cucumber tests with the "report" profile:

`$ cucumber -p report` or 

`$ cucumber -p report features/address.feature` (eg for one feature)

This will create a .json file in the ~/features/cucumber-report directory which details the results of the cucumber 
tests. The file will be embedded with screenshots of any failed tests.

To convert the .json into a .html file, execute:

`$ ruby features/support/report_builder.rb`

This will create the .html in the features/cucumber-report directory. Open in browser by right-clicking the file and 
going to 'Open in Browser'. 

Running smoke tests
$ bundle exec cucumber --tags @smoke

### Brakeman

[Brakeman](https://github.com/presidentbeef/brakeman) is a static analysis tool which checks Ruby on Rails applications for security vulnerabilities.

