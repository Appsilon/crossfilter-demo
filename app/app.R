library(shiny)
library(magrittr)

ships <- read.csv("ships.csv")

ui <- shinyUI(fixedPage(style = "padding: 0",
    tags$div(style = "width: 50%; float: left", leaflet::leafletOutput("map")),
    tags$div(style = "width: 50%; float: right", DT::dataTableOutput("tbl"))
))

server <- shinyServer(function(input, output) {

  output$map <- leaflet::renderLeaflet({
    leaflet::leaflet(ships) %>%
      leaflet::addTiles() %>%
      leaflet::addMarkers()
  })

  in_bounding_box <- function(data, lat, long, bounds) {
   data %>%
      dplyr::filter(lat > bounds$south & lat < bounds$north & long < bounds$east & long > bounds$west)
  }

  data_map <- reactive({
    if (is.null(input$map_bounds)){
      ships
    } else {
      bounds <- input$map_bounds
        in_bounding_box(ships, lat, long, bounds)
    }
  })

  output$tbl <- DT::renderDataTable({
    DT::datatable(data_map(), extensions = "Scroller", style = "bootstrap", class = "compact", width = "100%",
                  options = list(deferRender = TRUE, scrollY = 300, scroller = TRUE,  dom = 'tp'))
  })

})

# Run the application
shinyApp(ui = ui, server = server)
