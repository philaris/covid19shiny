library(shiny)
assign('%>%', base::getExportedValue('magrittr', '%>%'))

options(scipen=15)

cases <- readr::read_csv('/srv/data/cases.csv')
deaths <- readr::read_csv('/srv/data/deaths.csv')

lst <- list('Cases' = cases, 'Deaths' = deaths)

date_labeled <- function(tb, country) {
  cntry.tb <- tb %>%
    dplyr::filter(is.na(.data[['Province/State']])) %>%
    dplyr::filter(.data[['Country/Region']] == country) %>%
    dplyr::select(-c('Province/State', 'Country/Region', 'Lat', 'Long'))
  assertthat::assert_that(nrow(cntry.tb) == 1L)
  nums <- as.numeric(cntry.tb)
  dts <- as.Date(colnames(cntry.tb), format = '%m/%d/%y')
  names(nums) <- dts
  return(nums)
}

ui <- fluidPage(
  titlePanel("COVID-19 cases and deaths"),
  sidebarLayout(
    sidebarPanel(
      shiny::textOutput('last_date'),
      shiny::selectInput("location", "Location:",
                         choices = c(
                           'Belgium',
                           'Brazil',
                           'China',
                           'France',
                           'Germany',
                           'Greece',
                           'India',
                           'Israel',
                           'Italy',
                           'Japan',
                           'Morocco',
                           'Netherlands',
                           'Portugal',
                           'Russia',
                           'Spain',
                           'Sweden',
                           'Switzerland',
                           'United Kingdom',
                           'US'
                         ),
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


server <- function(input, output) {
  output[['covid_plot']] <- shiny::renderPlot({
    barplot(date_labeled(lst[[input[['ts_type']]]], input[['location']]), main = '')
  })
  output[['diff_plot']] <- shiny::renderPlot({
    barplot(diff(date_labeled(lst[[input[['ts_type']]]], input[['location']])), main = 'diff')
  })
  output[['last_date']] <- shiny::renderText({
    as.character(as.Date(tail(colnames(lst[[input[['ts_type']]]]), n = 1L), format = '%m/%d/%y'))
  })
}


shiny::shinyApp(ui = ui, server = server)
