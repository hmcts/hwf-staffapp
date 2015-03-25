FROM ministryofjustice/ruby:2.1.5-webapp-onbuild

ENV UNICORN_PORT 3000

# runit needs inittab
RUN touch /etc/inittab

RUN apt-get update && apt-get install -y 

EXPOSE $UNICORN_PORT

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
