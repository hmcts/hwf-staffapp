FROM ministryofjustice/ruby:2.1.5-webapp-onbuild

ENV RUBY_VERSION 2.1.5

ENV UNICORN_PORT 3000

# runit needs inittab
RUN touch /etc/inittab

RUN apt-get update && apt-get install -y

EXPOSE $UNICORN_PORT

CMD ./run.sh
