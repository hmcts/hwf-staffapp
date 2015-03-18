FROM ministryofjustice/ruby:2.1.5-webapp-onbuild

ENV UNICORN_PORT 3000

# runit needs inittab
RUN touch /etc/inittab

RUN apt-get update && apt-get install -y \
      pdftk \
      openjdk-7-jdk

RUN mkdir -p /usr/local/bin \
    && wget -O /usr/local/bin/lein \
      https://raw.githubusercontent.com/technomancy/leiningen/2.4.2/bin/lein \
    && chmod +x /usr/local/bin/lein

    
RUN mkdir -p   /etc/service/fr-staffapp
COPY ./docker/runit/runit-service /etc/service/fr-staffapp/run
RUN chmod +x  /etc/service/fr-staffapp/run

EXPOSE $UNICORN_PORT

CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]


