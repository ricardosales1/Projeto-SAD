library(readr)
library(janitor)
library(stringr)
library(dplyr)
library(fastDummies)

# 0 - Cria pasta clean se não existir
if (!dir.exists("dataset/clean")) {
  dir.create("dataset/clean", recursive = TRUE)
}

# 1 - Carrega os 4 datasets raw
raw_bike_sharing_system <- read_csv("dataset/raw_bike_sharing_system.csv")
raw_cities_weather_forecast <- read_csv("dataset/raw_cities_weather_forecast.csv")
raw_seoul_bike_sharing <- read_csv("dataset/raw_seoul_bike_sharing.csv")
raw_worldcities <- read_csv("dataset/raw_worldcities.csv")

# 2 - Cria lista com os datasets para facilitar o processamento em loop
datasets <- list(
  bike_sharing = raw_bike_sharing_system,
  cities_weather = raw_cities_weather_forecast,
  seoul_bike = raw_seoul_bike_sharing,
  world_cities = raw_worldcities
)

# 3 - Função para limpeza geral: padronizar nomes, remover links, extrair anos, tratar NA
clean_dataset <- function(df) {
  df %>%
    clean_names() %>%
    mutate(across(where(is.character), ~ str_remove_all(., "\\[.*?\\]"))) %>%
    mutate(across(
      contains(c("year", "date")),
      ~ str_extract(., "\\d{4}") %>% as.integer(),
      .names = "{.col}_num"
    )) %>%
    mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))
}

# 4 - Função específica para o seoul_bike: aplica limpeza e cria dummies para variáveis categóricas
clean_seoul_bike <- function(df) {
  df_clean <- clean_dataset(df)
  
  df_dummies <- fastDummies::dummy_cols(
    df_clean,
    select_columns = c("seasons", "holiday", "functioning_day"),
    remove_first_dummy = FALSE,     # agora mantém TODAS as categorias
    remove_selected_columns = TRUE
  )
  
  return(df_dummies)
}

# 5 - Processa todos datasets, usando função específica para seoul_bike
for (name in names(datasets)) {
  if (name == "seoul_bike") {
    cleaned_df <- clean_seoul_bike(datasets[[name]])
  } else {
    cleaned_df <- clean_dataset(datasets[[name]])
  }
  
  write_csv(cleaned_df, paste0("dataset/clean/clean_", name, ".csv"))
}

print(paste("Arquivos limpos salvos em dataset/clean:", list.files("dataset/clean")))









