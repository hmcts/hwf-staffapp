#!/bin/bash
cd /usr/src/app
case ${DOCKER_STATE} in
migrate)
    echo "running migrate"
    bundle exec rake db:migrate
    ;;
seed)
    echo "running seed"
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
vagrant)
    echo "running vagrant"
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
create)
    echo "running create"
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
setup)
    echo 'running setup'
    bundle exec rake db:setup
    ;;
esac

ROLE="${1:-app}"
case ${ROLE} in
worker)
    echo "running worker"
    bundle exec rake jobs:work
    ;;
*)
    echo "running app"
    bundle exec unicorn -c config/unicorn.rb -p $UNICORN_PORT
    ;;
esac
