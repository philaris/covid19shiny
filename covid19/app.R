library(shiny)
assign('%>%', base::getExportedValue('magrittr', '%>%'))

options(scipen=15)

date_labeled <- function(tb, country) {
  provcntry.tb <- tb %>%
    dplyr::filter(.data[['Country/Region']] == country) %>%
    dplyr::select(-c('Country/Region', 'Lat', 'Long'))
  has_na_province <- any(is.na(provcntry.tb[['Province/State']]))
  cntry.tb <- if (has_na_province) {
    provcntry.tb %>%
      dplyr::filter(is.na(.data[['Province/State']])) %>%
      dplyr::select(-'Province/State')
  } else {
    provcntry.tb %>%
      dplyr::select(-'Province/State') %>%
      colSums()
  }
  assertthat::assert_that(nrow(cntry.tb) == 1L || is.numeric(cntry.tb))
  nums <- as.numeric(cntry.tb)
  dts <- as.Date(names(cntry.tb), format = '%m/%d/%y')
  names(nums) <- dts
  return(nums)
}

ui <- fluidPage(
  tags[['head']](
    tags[['meta']](
      name = 'google-site-verification',
      content = 'TTIuTACji3mZAjdejEI6xtHt7quS8jMf2LwGIrD3OIw'
    )
  ),
  titlePanel("COVID-19 cases and deaths"),
  sidebarLayout(
    sidebarPanel(
      shiny::textOutput('last_date'),
      shiny::selectInput("location", "Location:",
                         choices = c(
                           'Austria',
                           'Belgium',
                           'Brazil',
                           'China',
                           'Denmark',
                           'France',
                           'Germany',
                           'Greece',
                           'Hungary',
                           'India',
                           'Israel',
                           'Italy',
                           'Japan',
                           'Morocco',
                           'Netherlands',
                           'Portugal',
                           'Russia',
                           'Singapore',
                           'Spain',
                           'Sweden',
                           'Switzerland',
                           'United Kingdom',
                           'US'
                         ),
                         selected = 'Greece',
                         multiple = FALSE),
      shiny::selectInput("ts_type", "Timeseries:",
                         choices = c(
                           'Cases',
                           'Deaths'
                         ),
                         multiple = FALSE),
      '(data from JHU CSSE)',
      width = 3
    ),

    mainPanel(
      shiny::plotOutput('covid_plot'),
      shiny::plotOutput('diff_plot')
    )
  )
)

file_or_web <- function(fname, url) {
  if (file.exists(fname)) fname else url
}

server <- function(input, output) {
  fcases <- file_or_web(
    '/srv/data/cases.csv',
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')
  message('INFO: Using ', fcases)
  fdeaths <- file_or_web(
    '/srv/data/deaths.csv',
    'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv'
  )
  message('INFO: Using ', fdeaths)
  cases <- readr::read_csv(fcases)
  deaths <- readr::read_csv(fdeaths)
  lst <- list('Cases' = cases, 'Deaths' = deaths)

  output[['covid_plot']] <- shiny::renderPlot({
    barplot(date_labeled(lst[[input[['ts_type']]]], input[['location']]), main = '')
  })
  output[['diff_plot']] <- shiny::renderPlot({
    mp <- barplot(diff(date_labeled(lst[[input[['ts_type']]]], input[['location']])),
                  main = 'daily with right-aligned 7-day average')
    lines(mp, zoo::rollmean(diff(date_labeled(lst[[input[['ts_type']]]], input[['location']])),
                            k = 7, fill = 'extend', align = 'right'), col = 'blue')
  })
  output[['last_date']] <- shiny::renderText({
    as.character(as.Date(tail(colnames(lst[[input[['ts_type']]]]), n = 1L), format = '%m/%d/%y'))
  })
}


shiny::shinyApp(ui = ui, server = server)
