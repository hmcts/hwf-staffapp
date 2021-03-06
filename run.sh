#!/bin/bash

ROLE1="${ROLE:-app}"
PHUSION_SERVICE="${PHUSION:-false}"
case ${PHUSION_SERVICE} in
true)
    echo "running as service"
    cd /home/app/
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
        case ${ROLE1} in
        worker)
            echo "running worker"
            bundle exec rake jobs:work
            ;;
        *)
            echo "running app"
            bundle exec puma -p ${UNICORN_PORT:-8080} -C ./config/puma.rb -e ${RAILS_ENV:-production}
            ;;
        esac
    ;;
*)
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
        case ${ROLE1} in
        worker)
            echo "running worker"
            bundle exec rake jobs:work
            ;;
        *)
            echo "running app"
            bundle exec puma -p ${UNICORN_PORT:-8080} -C ./config/puma.rb -e ${RAILS_ENV:-production}
            ;;
        esac
    ;;
esac
