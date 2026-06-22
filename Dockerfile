FROM hmctsprod.azurecr.io/imported/library/ruby:4.0.5-alpine3.23

# Adding argument support for ping.json
ARG APPVERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APPVERSION=${APPVERSION}
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
ENV NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_COMPLETED_PAPER_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_PAPER_TEMPLATE_ID=replace_this_at_build_time
ENV NOTIFY_DWP_DOWN_TEMPLATE_ID=replace_this_at_build_time

# fix to address http://tzinfo.github.io/datasourcenotfound - PET ONLY
ARG DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache \
        libc6-compat \
        git build-base curl-dev nodejs npm libpq-dev postgresql-client tzdata \
        xvfb fluxbox x11vnc st yaml-dev libffi-dev

# Yarn 4 (Berry) is provisioned via Corepack, pinned by the "packageManager"
# field in package.json. Alpine's nodejs package does not bundle Corepack and
# its yarn package is the legacy 1.x classic, so install Corepack explicitly.
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN npm install -g corepack \
 && corepack enable

ENV UNICORN_PORT=3000
EXPOSE $UNICORN_PORT

RUN mkdir -p /home/app
WORKDIR /home/app

COPY Gemfile Gemfile.lock /home/app/
RUN gem install bundler -v 4.0.10 \
 && bundle config set --local without 'test development' \
 && bundle config set --local force_ruby_platform true
RUN bundle install

# Match master: HOME points at the app dir so Corepack's cache is writable by
# the non-root runtime user, and the Yarn binary provisioned here is reused at
# runtime. corepack install provisions the Yarn version from package.json.
ENV HOME=/home/app
ENV COREPACK_HOME=/home/app/.corepack

COPY package.json yarn.lock .yarnrc.yml /home/app/
RUN corepack install \
 && yarn install --immutable

# running app as a servive
ENV PHUSION=true

COPY . /home/app

CMD ["sh", "-c", "bundle exec rake assets:precompile RAILS_ENV=production SECRET_TOKEN=blah && \
     bundle exec rake static_pages:generate RAILS_ENV=production SECRET_TOKEN=blah && \
     sh ./run.sh"]
