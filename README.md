# Fee Remissions - Staff App

[![Code Climate](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp) [![Build Status](https://travis-ci.org/ministryofjustice/fr-staffapp.svg?branch=master)](https://travis-ci.org/ministryofjustice/fr-staffapp)

## Overview

This app is used by staff in the courts and tribunals to enter data regarding fee remission applications, 
record the decision, and collect statistics.

## Project Standards

- Authentications via Devise / CanCanCan
- Rspec features, not cucumber
- Slim templating language
- Foundation view framework
- Coffeescript in preference to Javascript

## Pre-requisites
To run the headless tests you will need to install quicktime for capybara-webkit:
```
brew install qt 
```
You will need to run the following to enable capybara-webkit in ubuntu environments:
```
sudo apt-get install libqt4-dev
sudo apt-get install xvfb
```

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
