#!/bin/bash

case ${DOCKER_STATE} in
migrate)
    echo "Running migrate"
    bundle exec rake db:migrate
    ;;
create)
    echo "Running create"
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
esac

bundle exec rake jobs:work &
bundle exec puma -p ${UNICORN_PORT:-8080} -C ./config/puma.rb -e ${RAILS_ENV:-production}
