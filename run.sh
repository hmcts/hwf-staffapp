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
bundle exec unicorn -p 3000 -c ./config/unicorn.rb

ROLE="${1:-app}"
case ${ROLE} in
worker)
    echo "creating rails_runner.sh for running rails runners via a cron job"
    env > env.sh
    sed -i '/ADMIN_IP_RANGES.*/d' env.sh
    sed -i '/NEW_RELIC_APP_NAME.*/d' env.sh
    cat env.sh | xargs > rails_runner.sh
    PATH_APPENDS='PATH=/usr/local/bundle/bin:$PATH GEM_HOME=/usr/local/bundle GEM_PATH=/usr/local/bundle:$GEM_PATH'
    echo '#!/bin/bash' > rails_runner.sh
    echo "cd /usr/src/app" >> rails_runner.sh
    echo "cd /usr/src/app && $(cat env.sh | xargs) $PATH_APPENDS bin/rails runner -e production \$1" >> rails_runner.sh
    chmod a+x rails_runner.sh

    echo "installing and running cron"
    apt-get update
    apt-get install -y cron
    cron

    echo "running whenever to create crontab"
    bundle exec whenever -w

    echo "running worker"
    bundle exec rake jobs:work
    ;;
*)
    echo "running app"
    bundle exec unicorn -c config/unicorn.rb -p $UNICORN_PORT
    ;;
esac
