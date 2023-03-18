FROM rocker/shiny-verse:4.2.3

MAINTAINER Panagiotis Cheilaris "philaris@gmail.com"

RUN apt-get update && apt-get install -y cron

RUN install2.r -e zoo

RUN mkdir -p /srv/data

COPY covid19/get_data.R /srv/

COPY covid19/cronjobs /srv/
RUN crontab /srv/cronjobs

COPY covid19/app.R /srv/shiny-server/

RUN touch /var/log/cron.log

COPY covid19/download_cron_init /
RUN chmod a+rx /download_cron_init

CMD ["/download_cron_init"]
