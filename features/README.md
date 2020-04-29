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

### Running cross browser and device tests using Sauce Labs

Replace 'SAUCE_USERNAME' and 'SAUCE_ACCESS_KEY' in hwf-publicapp/.env.test with your account details

Run tunnel:
$ ~/sc-4.4.7-osx/bin/sc -u <SAUCE_USERNAME> -k <SAUCE_ACCESS_KEY> --se-port 4449
Replace <SAUCE_USERNAME> and <SAUCE_ACCESS_KEY> with your account details

Wait for 'Sauce Connect is up, you may start your tests.'

[Add the tag '@saucelabs' to a scenario/s that you want to run.]

To run Sauce Labs feature using specific browser:
$ DRIVER=saucelabs SAUCELABS_BROWSER=ie11_win7 cucumber --tags @saucelabs

To run Sauce Labs feature on all devices and browsers:
$ bin/run_saucelabs

### Screenshots and HTML

To open screenshot or html:

$ open ./screenshot_cucumber_Start-now_2017-04-24-11-40-28.186.png

$ open ./screenshot_cucumber_Start-now_2017-04-24-11-40-28.186.html