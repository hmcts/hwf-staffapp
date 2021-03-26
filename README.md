# Help With Fees - Staff App
[![Code Climate](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp/coverage?sort=covered_percent&sort_direction=asc)

[![Build Status](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_apis/build/status/Help%20with%20Fees/hwf-staffapp?branchName=develop)](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_build/latest?definitionId=26&branchName=develop)

## Overview

This app is used by staff in the courts and tribunals to enter data regarding help with fees applications,
record the decision, and collect statistics.

## Project Standards

- Authentications via Devise / CanCanCan
- Rspec features, not cucumber
- Slim templating language
- JavaScript in preference to Coffeescript

## Pre-requisites
To run the headless tests you will need to install quicktime for capybara-webkit:
```
brew install qt
```
You will need to run the following to enable capybara-webkit in ubuntu environments:
```
sudo apt-get install qt5-default libqt5webkit5-dev
sudo apt-get install xvfb
```

You will also need to install govuk-frontend library
```
npm install --save govuk-frontend
```
Mimemagic gem has a dependency so you need to install this on your machine first
```brew install shared-mime-info.```

#### Creating initial user
There is a rake task that takes email, password and role

```
rake user:create
```

If you want to add any custom options, use the below as an example:

```
rake "user:create[user@hmcts.gsi.gov.uk, 123456789, admin, name]"
```
__Note:__ the quotes around the task are important!


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