library(shiny)
library(magrittr)

ships <- read.csv("ships.csv")

ui <- shinyUI(fluidPage(
  fluidRow(
    column(6, leaflet::leafletOutput("map")),
    column(6, DT::dataTableOutput("tbl"))
  )
))

server <- shinyServer(function(input, output) {
  
  output$map <- leaflet::renderLeaflet({
    leaflet::leaflet(ships) %>% leaflet::addTiles() %>% leaflet::addMarkers()
  })
  
  data_map <- reactive({
    if (is.null(input$map_bounds)){
      ships
    } else {
      bounds <- input$map_bounds
      ships %>%
        dplyr::filter(lat > bounds$south & lat < bounds$north & long < bounds$east & long > bounds$west)
    }
  })
  
  output$tbl <- DT::renderDataTable({
    DT::datatable(data_map(), extensions = "Scroller", style = "bootstrap", class = "compact", width = "100%",
                  options = list(deferRender = TRUE, scrollY = 300, scroller = TRUE))
  })
  
})

# Run the application 
shinyApp(ui = ui, server = server)