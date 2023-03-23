FROM ruby:3.2-buster

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
ENV NOTIFY_COMPLETED_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_PAPER_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID replace_this_at_build_time
ENV NOTIFY_COMPLETED_CY_PAPER_TEMPLATE_ID replace_this_at_build_time

# fix to address http://tzinfo.github.io/datasourcenotfound - PET ONLY
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get install -qy tzdata npm --no-install-recommends shared-mime-info && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN mkdir -p /home/app
WORKDIR /home/app

COPY Gemfile /home/app
COPY Gemfile.lock /home/app
RUN gem install bundler -v 2.4.8
RUN bundle config set --local without 'test development'
RUN bundle config set force_ruby_platform true
RUN bundle install

# running app as a servive
ENV PHUSION true

COPY . /home/app
RUN npm install
RUN bash -c "bundle exec rake assets:precompile RAILS_ENV=production SECRET_TOKEN=blah"
RUN bash -c "bundle exec rake static_pages:generate RAILS_ENV=production SECRET_TOKEN=blah"

COPY run.sh /home/app/run
RUN chmod +x /home/app/run
CMD ["./run"]
