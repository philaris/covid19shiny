# COVID-19 Shiny plot app

This is a Shiny app that shows COVID-19 plots for several countries.
Every time the container starts, it downloads data from JHU CSSE
and it repeats the download daily.

### Docker image

If you have docker, you can start the image at https://hub.docker.com/r/philaris/covid19shiny as follows:
```
docker run --rm -p3838:3838 --name covid19 philaris/covid19shiny
```
Then, you can point your browser to <http://localhost:3838>.

There is also a docker compose file in compose-covid19 that serves
the app through
the HTTPS portal <https://github.com/SteveLTN/https-portal>.
Enter the directory and run it, e.g., as follows:
```
COVID19HOST=covid19.example.org docker-compose up
```
Then, you can point your browser to <https://covid19.example.org>.
