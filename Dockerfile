FROM rocker/shiny-verse:latest

COPY covid19/app.R /srv/shiny-server/
