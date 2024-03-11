FROM ruby:3.3-alpine AS assets
RUN addgroup app --gid 1000
RUN adduser -SD -u 1000 --shell /bin/bash --home /home/app app app
RUN chown -R app:app /usr/local/bundle
COPY --chown=app:app . /home/app/
ENV RAILS_ENV=production
ENV HOME=/home/app
RUN apk update && apk add --no-cache libc6-compat && \
    apk add --no-cache --virtual .build-tools git build-base curl-dev nodejs yarn npm libpq-dev postgresql-client tzdata && \
    apk add --no-cache xvfb fluxbox x11vnc st \
    cd /home/app/&& \
    BUNDLER_VERSION=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | awk '{$1=$1};1') && \
    gem install bundler:$BUNDLER_VERSION invoker && \
    bundle config set without 'test development' && \
    bundle config set with 'assets production' && \
    bundle config set deployment 'true' && \
    bundle install --no-cache --jobs=5 --retry=3 && \
    bundle exec rails assets:precompile SECRET_KEY_BASE=doesntmatter && \
    chown -R app:app /usr/local/bundle && \
    apk del .build-tools



FROM ruby:3.3-alpine

# Adding argument support for ping.json
ARG APPVERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APPVERSION ${APPVERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}
ENV NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_PAPER_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_PAPER_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_DWP_DOWN_TEMPLATE_ID replace_this_at_build_time

# fix to address http://tzinfo.github.io/datasourcenotfound - PET ONLY
ARG DEBIAN_FRONTEND=noninteractive

RUN apk update && apk add --no-cache libc6-compat && \
    apk add --no-cache --virtual .build-tools git build-base curl-dev nodejs yarn npm libpq-dev postgresql-client tzdata && \
    apk add --no-cache xvfb fluxbox x11vnc st


ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN mkdir -p /home/app
WORKDIR /home/app

COPY Gemfile /home/app
COPY Gemfile.lock /home/app
RUN gem install bundler -v 2.5.6

RUN bundle config set --local without 'test development'
RUN bundle config set force_ruby_platform true
RUN bundle install

# running app as a servive
ENV PHUSION true

COPY . /home/app
RUN npm install

CMD ["sh", "-c", "bundle exec rake assets:precompile RAILS_ENV=production SECRET_TOKEN=blah && \
     bundle exec rake static_pages:generate RAILS_ENV=production SECRET_TOKEN=blah && \
     sh ./run.sh"]


