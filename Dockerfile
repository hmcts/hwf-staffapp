FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

ENV UNICORN_PORT 3000

# runit needs inittab
RUN touch /etc/inittab

RUN apt-get update && apt-get install -y

EXPOSE $UNICORN_PORT

#SECRET_TOKEN set here because otherwise devise blows up during the precompile.
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_TOKEN=blah
RUN bundle exec rake static_pages:generate RAILS_ENV=production SECRET_TOKEN=blah

# CMD ./run.sh
ENTRYPOINT ["./run.sh"]
