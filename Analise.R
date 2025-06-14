library(DBI)
library(RSQLite)
library(dplyr)
library(readr)
library(ggplot2)

# 0 - Conectar / criar base SQLite local
con <- dbConnect(SQLite(), "dataset/bikedata.sqlite")

# 1 - Importar os 4 datasets cleans como tabelas na base SQLite
tables <- list(
  seoul_bike = read_csv("dataset/clean/clean_seoul_bike.csv"),
  cities_weather = read_csv("dataset/clean/clean_cities_weather.csv"),
  bike_sharing = read_csv("dataset/clean/clean_bike_sharing.csv"),
  world_cities = read_csv("dataset/clean/clean_world_cities.csv")
)

for (tbl_name in names(tables)) {
  dbWriteTable(con, tbl_name, tables[[tbl_name]], overwrite = TRUE)
}

# --- TAREFA 1: Contagem de registos no seoul_bike
q1 <- "SELECT COUNT(*) AS total_registos FROM seoul_bike"
print(dbGetQuery(con, q1))

# --- TAREFA 2: Quantas horas tiveram alugueres diferentes de zero
q2 <- "
  SELECT COUNT(*) AS horas_com_bicicletas 
  FROM seoul_bike
  WHERE rented_bike_count > 0
"
print(dbGetQuery(con, q2))

# --- TAREFA 3: Previsão do tempo para Seul nas próximas 3 horas
q3 <- "
  SELECT *
  FROM cities_weather
  WHERE city = 'Seoul'
  ORDER BY dt_txt
  LIMIT 3
"
print(dbGetQuery(con, q3))

# --- TAREFA 4: Estações incluídas no dataset Seoul Bike Sharing
q4 <- "
SELECT
  CASE
    WHEN seasons_Autumn = 1 THEN 'Autumn'
    WHEN seasons_Spring = 1 THEN 'Spring'
    WHEN seasons_Summer = 1 THEN 'Summer'
    WHEN seasons_Winter = 1 THEN 'Winter'
  END AS seasons
FROM seoul_bike
GROUP BY seasons
"
print(dbGetQuery(con, q4))

# --- TAREFA 5: Alugueres médios por hora do dia
q5 <- "
  SELECT hour, AVG(rented_bike_count) AS alugueres_medios
  FROM seoul_bike
  GROUP BY hour
  ORDER BY alugueres_medios DESC
"
print(dbGetQuery(con, q5))

# --- TAREFA 6: Alugueres médios por temperatura
q6 <- "
  SELECT ROUND(temperature) AS temp_round,
         AVG(rented_bike_count) AS alugueres_medios
  FROM seoul_bike
  GROUP BY temp_round
  ORDER BY temp_round
"
print(dbGetQuery(con, q6))

# --- TAREFA 7: Popularidade horária e temperatura por estação
q7 <- "
  SELECT
    CASE
      WHEN seasons_Autumn = 1 THEN 'Autumn'
      WHEN seasons_Spring = 1 THEN 'Spring'
      WHEN seasons_Summer = 1 THEN 'Summer'
      WHEN seasons_Winter = 1 THEN 'Winter'
    END AS seasons,
    hour,
    AVG(temperature) AS temp_media,
    AVG(rented_bike_count) AS alugueres_media
  FROM seoul_bike
  GROUP BY seasons, hour
  ORDER BY alugueres_media DESC
  LIMIT 10
"
print(dbGetQuery(con, q7))

# --- TAREFA 8: Estatísticas de aluguer por estação
q8 <- "
  SELECT
    CASE
      WHEN seasons_Autumn = 1 THEN 'Autumn'
      WHEN seasons_Spring = 1 THEN 'Spring'
      WHEN seasons_Summer = 1 THEN 'Summer'
      WHEN seasons_Winter = 1 THEN 'Winter'
    END AS seasons,
    AVG(rented_bike_count) AS media,
    MIN(rented_bike_count) AS minimo,
    MAX(rented_bike_count) AS maximo,
    (AVG(rented_bike_count * rented_bike_count) - AVG(rented_bike_count) * AVG(rented_bike_count)) AS variancia,
    SQRT(AVG(rented_bike_count * rented_bike_count) - AVG(rented_bike_count) * AVG(rented_bike_count)) AS desvio_padrao
  FROM seoul_bike
  GROUP BY seasons
  ORDER BY media DESC
"
print(dbGetQuery(con, q8))

# --- TAREFA 9: Sazonalidade meteorológica
q9 <- "
  SELECT
    CASE
      WHEN seasons_Autumn = 1 THEN 'Autumn'
      WHEN seasons_Spring = 1 THEN 'Spring'
      WHEN seasons_Summer = 1 THEN 'Summer'
      WHEN seasons_Winter = 1 THEN 'Winter'
    END AS seasons,
    AVG(temperature) AS temperatura_media,
    AVG(humidity) AS humidade_media,
    AVG(wind_speed) AS wind_speed_media,
    AVG(visibility) AS visibilidade_media,
    AVG(dew_point_temperature) AS dew_point_media,
    AVG(solar_radiation) AS solar_radiation_media,
    AVG(rainfall) AS precipitacao_media,
    AVG(snowfall) AS queda_neve_media,
    AVG(rented_bike_count) AS alugueres_media
  FROM seoul_bike
  GROUP BY seasons
  ORDER BY alugueres_media DESC
"
print(dbGetQuery(con, q9))

# --- TAREFA 10: Top 10 cidades com mais sistemas de bicicletas partilhadas
q10 <- "
  SELECT city_region, COUNT(*) AS total_sistemas
  FROM bike_sharing
  GROUP BY city_region
  ORDER BY total_sistemas DESC
  LIMIT 10
"
print(dbGetQuery(con, q10))

# --- TAREFA 11: Top 10 cidades mais populosas com bicicletas partilhadas
q11 <- "
  SELECT wc.city, wc.country, wc.population
  FROM world_cities wc
  INNER JOIN bike_sharing bs
    ON LOWER(wc.city) = LOWER(bs.city_region)
  GROUP BY wc.city, wc.country
  ORDER BY wc.population DESC
  LIMIT 10
"
print(dbGetQuery(con, q11))

