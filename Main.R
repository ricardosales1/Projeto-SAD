library(shiny)
library(leaflet)
library(tidyverse)
library(lubridate)
library(httr)
library(jsonlite)
library(DT)
library(plotly)
library(bslib)

# Chave da API
api_key <- "e1eb6d19a92ee26ab8489d3f3ebb0fe9"

# Cidades e coordenadas
cities <- tibble(
  city = c("New York", "Paris", "Suzhou", "London"),
  country = c("US", "FR", "CN", "GB"),
  lat = c(40.7128, 48.8566, 31.2989, 51.5074),
  lon = c(-74.0060, 2.3522, 120.5853, -0.1278)
)

# Função para buscar dados da API OpenWeather
get_weather_forecast_city <- function(city_name, country_code) {
  city_query <- URLencode(paste0(city_name, ",", country_code))
  
  url <- paste0(
    "https://api.openweathermap.org/data/2.5/forecast?q=", city_query,
    "&appid=", api_key,
    "&units=metric&lang=pt"
  )
  
  response <- GET(url)
  if (response$status_code != 200) {
    warning(paste("Erro ao buscar dados para", city_name))
    return(NULL)
  }
  
  data <- content(response, "text", encoding = "UTF-8")
  weather_json <- fromJSON(data)
  
  forecast_list <- weather_json$list
  n <- length(forecast_list$dt)
  
  safe_extract_3h <- function(x) {
    if (is.list(x) && !is.null(x$`3h`)) return(x$`3h`)
    return(0)
  }
  
  rainfall <- if (!is.null(forecast_list$rain)) sapply(forecast_list$rain, safe_extract_3h) else rep(0, n)
  snowfall <- if (!is.null(forecast_list$snow)) sapply(forecast_list$snow, safe_extract_3h) else rep(0, n)
  
  tibble(
    dt = as_datetime(forecast_list$dt),
    temperature = forecast_list$main$temp,
    humidity = forecast_list$main$humidity,
    wind_speed = forecast_list$wind$speed,
    visibility = forecast_list$visibility,
    solar_radiation = 0,
    rainfall = rainfall,
    snowfall = snowfall,
    dew_point_temperature = 0
  )
}

# Função para criar dummies de estação
create_season_dummies <- function(dates) {
  month <- month(dates)
  season <- case_when(
    month %in% c(3,4,5) ~ "Spring",
    month %in% c(6,7,8) ~ "Summer",
    month %in% c(9,10,11) ~ "Autumn",
    TRUE ~ "Winter"
  )
  tibble(
    seasons_Spring = as.integer(season == "Spring"),
    seasons_Summer = as.integer(season == "Summer"),
    seasons_Autumn = as.integer(season == "Autumn"),
    seasons_Winter = as.integer(season == "Winter")
  )
}

# UI
ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly", version = 5),
  titlePanel("Previsão de Demanda de Bicicletas e Clima - Cidades"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("selected_city", "Selecione a Cidade:",
                  choices = cities$city, selected = "New York"),
      actionButton("btn_update", "Atualizar Dados"),
      br(), br(),
      helpText("Fonte dos dados meteorológicos: OpenWeather API")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Mapa", leafletOutput("map", height = 400)),
        tabPanel("Tabela", DT::DTOutput("table_forecast")),
        tabPanel("Gráfico", plotlyOutput("plot_forecast"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # Carregar modelo treinado
  model_lasso <- readRDS("Modelo.rds")
  
  forecast_data <- eventReactive(input$btn_update, {
    city_sel <- input$selected_city
    city_info <- filter(cities, city == city_sel)
    
    weather <- get_weather_forecast_city(city_info$city, city_info$country)
    if (is.null(weather)) return(NULL)
    
    season_dummies <- create_season_dummies(weather$dt)
    weather <- bind_cols(weather, season_dummies)
    
    weather$hour <- factor(hour(weather$dt), levels = levels(model_lasso$model$hour))
    
    pred <- predict(model_lasso, newdata = weather)
    
    demand <- as.numeric(pred)
    demand[demand < 0] <- 0
    
    weather %>%
      mutate(
        demand = round(demand),
        city = city_info$city,
        lat = city_info$lat,
        lon = city_info$lon
      )
  })
  
  output$map <- renderLeaflet({
    df <- forecast_data()
    if (is.null(df) || nrow(df) == 0) {
      leaflet() %>% addTiles()
    } else {
      max_demand <- max(df$demand)
      city <- unique(df$city)
      lat <- unique(df$lat)
      lon <- unique(df$lon)
      
      leaflet() %>%
        addTiles() %>%
        addCircleMarkers(
          lng = lon, lat = lat,
          radius = sqrt(max_demand) / 2,
          color = "blue",
          fillOpacity = 0.6,
          label = paste0(city, ": ", max_demand, " bicicletas (máx. 5 dias)")
        ) %>%
        setView(lng = lon, lat = lat, zoom = 10)
    }
  })
  
  output$table_forecast <- renderDT({
    df <- forecast_data()
    if (is.null(df) || nrow(df) == 0) return(NULL)
    
    df %>%
      mutate(
        Data = format(dt, "%d/%m/%Y"),
        Hora = format(dt, "%H:%M"),
        Temperatura = round(temperature, 1),
        Humidade = humidity,
        `Velocidade do Vento` = round(wind_speed, 1),
        `Radiação Solar` = solar_radiation,
        Chuva = rainfall,
        Neve = snowfall,
        `Demanda Prevista` = demand
      ) %>%
      select(
        Cidade = city, Data, Hora,
        Temperatura, Humidade, `Velocidade do Vento`,
        `Radiação Solar`, Chuva, Neve,
        `Demanda Prevista`
      )
  }, options = list(pageLength = 10))
  
  output$plot_forecast <- renderPlotly({
    df <- forecast_data()
    if (is.null(df) || nrow(df) == 0) return(NULL)
    
    p <- ggplot(df, aes(x = dt, y = demand)) +
      geom_line(color = "steelblue", size = 1) +
      geom_point(color = "darkblue", size = 1.5) +
      labs(
        title = paste("Previsão de Demanda -", input$selected_city),
        x = "Data/Hora", y = "Demanda Prevista"
      ) +
      theme_minimal(base_size = 14)
    
    ggplotly(p)
  })
}

# Run app
shinyApp(ui, server)






