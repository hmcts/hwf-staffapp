## Overview

This app is used by staff in the courts and tribunals to enter data regarding help with fees applications,
record the decision, and collect statistics.

## Project Standards

- Authentications via Devise / CanCanCan
- Rspec features, not cucumber
- Slim templating language
- JavaScript in preference to Coffeescript
- Propshaft instead of Sprotckets = https://github.com/rails/propshaft?tab=readme-ov-file

## Data changes tracking
Ww are using paper trail for detailed data chages tracking. But when we do one off data changes we need something simpler.
That's what is the DevNote model is for. When you make changes to date via script please make a relevant record in DevNote so we can
track the changes in exports (like raw data). I.E.
```
Application.last.dev_notes.create(note: 're-generating reference numner - bug fix')
```

## Redis
We are using Redis for step back navigation link. You will need to run a redis-server in order
for the application to work correctly.
We are using mock_redis in rspec to make it work it tests.

## Feature switching
Model FeatureSwitching have following attributes:
feature_key, activation_time, office_id, enabled. When apply you can "schedule" a feature to be active from a certain date or for
specific office. Feature switching table is managed manually from a rails console for now.

## Active Feature flag for post UCD changes
Run this in your localhost to enable UCD changes:
FeatureSwitching.create(feature_key: 'band_calculation', enabled: true)


## N+1 queries debugging
There is a gem called Bullet. If you want to check N+1 queries in development mode, you can uncomment
Bullet related lines in development.rb


## Delayed CRON Jobs (delayed_cron_job)
We need to keep an eye on the results of DWP checks. When the API is down the service will disable
benefit related applications. Then we re-run failed checks in 10 minutes intervals to see if the
API is back again. We are not using standard CRON table because Kubernetes have a bug. So we are using
delayed cron job that has the schedule in DB table. These tasks are checked by

```rake jobs:work```

that needs to run on the background, currently set up in rub.sh :
```rake jobs:work &```



## Delayed jobs for BenefitChecks
To set it up (if there is no record in DB) run this in rails console:
```BenefitCheckRerunJob.delay(cron: '*/10 * * * *').perform_now```

## Delayed jobs for DWP offline notification
Runs every 5 minutes
```DwpReportStatusJob.delay(cron: '*/5 * * * *').perform_now```

## Delayed jobs for HMRC data purge
Runs 10 minutes past midnight
```HmrcDataPurgeJob.delay(cron: '10 0 * * *').perform_now```

## Delayed jobs for Personal data purge
Runs every day at 1am
```PersonalDataPurgeJob.delay(cron: '0 1 * * *').perform_now```

## Delayed jobs for Abandoned Application data purge
Runs every day at 1am
```AbandonedApplicationPurgeJob.delay(cron: '0 1 * * *').perform_now```

## Delayed jobs for Old export file data purge
Runs every day at 2am
```OldFileExportPurgeJob.delay(cron: '0 2 * * *').perform_now```

## Front end library
You will need to install govuk-frontend library
```
yarn install
```

## Update existing frontend libraries
```
yarn upgrade --latest
```

## CSS + JS updates
We are now using propshaft, cssbundling-rails and jsbundling-rails. You will need to run
```
yarn build:css --watch
yarn build --watch
```
to build your assets you localhost for the first time. Then everytime you are toding any changes to JS or CSS.


Mimemagic gem has a dependency so you need to install this on your machine first
```brew install shared-mime-info.```

#### Creating initial user
There is a rake task that takes email, password and role

```
rake user:create
```

If you want to add any custom options, use the below as an example:

```
rake "user:create[user@hmcts.net, 12345678900, admin, name]"
```
__Note:__ the quotes around the task are important!

#### Run an applicants report for a finacial year

There is a rake task that creates the report

```
rake "reports:applicants[2021, 2022]"
```
this will generate a zip file applicants-2021-2022-fy.csv.zip

#### Run raw data extract for longer timescale

There is a rake task that creates the report

```
rake "reports:raw_data_extract[2021-01-01, 2022-12-31]"
```
this will generate a zip file raw_data-1-1-2021-31-12-2022.csv.zip

## Testing
### Benefit Check mock call
I added mock benefit check call. It's not mocking the call itself; it's just using a different library To generate request/response.
This is for testing on demo environments, AAT, and preview. So we can test the normal benefit check flow without calling the actual benefit_checker.
For now, there are 4 responses. If you are going to match one of these three National Insurance numbers, you will get the following responses.
Yes - Full outcome - NI number: 'SN789654A'
No - None outcome - NI number: 'SN789654B'
Undetermined - None outcome - NI number: 'SN789654C'

To turn this on you need to have a FAKE_BENEFIT_CHECK='true' set up in your env.


#### Run tests in parallel
Follow the [official guides](https://github.com/grosser/parallel_tests#setup-environment-from-scratch-create-db-and-loads-schema-useful-for-ci) to setup your local env


Run the specs in parallel
```
RAILS_ENV=test bundle exec rake parallel:spec
```

Run the cucumber features in parallel
```
CAPYBARA_SERVER_PORT=random bundle exec rake parallel:features
```

#### Cucumber test report
Cucumber report is enabled now. At the end of the test run you should see a link to a website.
When you run tests in parallel it will generate report per process so if you want to see one report only you should
run test directly without parallel functionality.

### Smoke test ###
Smoke tests are set up to run on CI not on local but if you want to do it on local
you can run it as
```
cucumber -p smoke
```
but before you do update this setup in capybara_driver_helper.rb

```
# Uncomment and set to your test URL to run tests against localhost
# ENV['TEST_URL'] = 'http://localhost:3000/'

if ENV['TEST_URL'] && ENV['RUN_SMOKE_TESTS'] == 'true'
  Capybara.app_host = ENV['TEST_URL']
  Capybara.run_server = false
else
```

Deployment versions trigger: 6
