FROM ministryofjustice/ruby:2.1.5-webapp-onbuild

ENV UNICORN_PORT 3000

ENV DB_HOST 10.0.2.2
ENV DB_PORT 5432 
ENV DB_NAME fr-staffapp_development 
ENV DB_USERNAME paulwyborn
ENV DB_PASSWORD ''
ENV SECRET_TOKEN bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ENV RAILS_ENV production
# runit needs inittab
RUN touch /etc/inittab

RUN apt-get update && apt-get install -y 

EXPOSE $UNICORN_PORT

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
