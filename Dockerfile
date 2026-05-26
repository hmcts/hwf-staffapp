# syntax=docker/dockerfile:1.4
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
        git build-base curl-dev nodejs yarn libpq-dev postgresql-client tzdata \
        xvfb fluxbox x11vnc st yaml-dev libffi-dev

ENV UNICORN_PORT=3000
EXPOSE $UNICORN_PORT

RUN mkdir -p /home/app
WORKDIR /home/app

COPY Gemfile Gemfile.lock /home/app/
RUN gem install bundler -v 4.0.10 \
 && bundle config set --local without 'test development' \
 && bundle config set --local force_ruby_platform true
RUN --mount=type=cache,target=/usr/local/bundle/cache \
    bundle install

COPY package.json yarn.lock /home/app/
RUN --mount=type=cache,target=/usr/local/share/.cache/yarn \
    yarn install --check-files --frozen-lockfile

# running app as a servive
ENV PHUSION=true

COPY . /home/app

CMD ["sh", "-c", "bundle exec rake assets:precompile RAILS_ENV=production SECRET_TOKEN=blah && \
     bundle exec rake static_pages:generate RAILS_ENV=production SECRET_TOKEN=blah && \
     sh ./run.sh"]
