library(pacman)
pacman::p_load(rvest, tidyverse, httr, stringr, magrittr, jsonlite, purrr)

if (!dir.exists("dataset")) dir.create("dataset")

##### COLETA 1 #####
url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"
data <- read_html(url)
bike_df <- data %>% html_element("table") %>% html_table()
write.csv(bike_df, "dataset/raw/raw_bike_sharing_system.csv", row.names = FALSE)

##### COLETA 2 #####
api_key <- 'e1eb6d19a92ee26ab8489d3f3ebb0fe9'

get_forecast <- function(city) {
  url <- "https://api.openweathermap.org/data/2.5/forecast"
  res <- GET(url, query = list(q = city, appid = api_key, units = "metric"))
  stop_for_status(res)
  data <- content(res, "text", encoding = "ISO-8859-1")
  json_data <- fromJSON(data, simplifyVector = FALSE)
  
  # json_data$list é uma lista de listas, vamos transformar em tibble
  list_data <- json_data$list
  
  # Extrai os dados para cada item da lista
  df <- map_dfr(list_data, function(x) {
    tibble(
      city = city,
      dt_txt = x$dt_txt,
      temp = purrr::pluck(x, "main", "temp") %||% NA_real_,
      temp_min = purrr::pluck(x, "main", "temp_min") %||% NA_real_,
      temp_max = purrr::pluck(x, "main", "temp_max") %||% NA_real_,
      humidity = purrr::pluck(x, "main", "humidity") %||% NA_real_,
      weather = purrr::pluck(x, "weather", 1, "main") %||% NA_character_,
      wind_speed = purrr::pluck(x, "wind", "speed") %||% NA_real_,
      wind_deg = purrr::pluck(x, "wind", "deg") %||% NA_real_
    )
  })
  
  return(df)
}

cities <- c("Seoul", "Washington, D.C.", "Paris", "Suzhou", "London", "New York")
cities_weather_df <- map_dfr(cities, get_forecast)
write.csv(cities_weather_df, "dataset/raw/raw_cities_weather_forecast.csv", row.names = FALSE)

##### COLETA 3 #####
download.file("https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw/raw_worldcities.csv", destfile = "dataset/raw/raw_worldcities.csv", mode = "wb")
download.file("https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw/raw_seoul_bike_sharing.csv", destfile = "dataset/raw/raw_seoul_bike_sharing.csv", mode = "wb")



