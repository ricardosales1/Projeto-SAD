library(tidyverse)
library(caret)
library(glmnet)

# Carregar e preparar os dados (renomear colunas com espaços)
df <- read_csv("dataset/clean/clean_seoul_bike.csv") %>%
  rename(
    holiday_No_Holiday = `holiday_No Holiday`,
    holiday_Holiday = `holiday_Holiday`,
    functioning_day_No = `functioning_day_No`,
    functioning_day_Yes = `functioning_day_Yes`
  ) %>%
  mutate(
    date = as.Date(date, format = "%d/%m/%Y"),
    hour = factor(hour, levels = 0:23)
  )

# Dividir dados em treino e teste
set.seed(123)
train_index <- createDataPartition(df$rented_bike_count, p = 0.7, list = FALSE)
train <- df[train_index, ]
test <- df[-train_index, ]

# Modelo 1: Variáveis meteorológicas
model1 <- lm(rented_bike_count ~ temperature + humidity + wind_speed + visibility +
               dew_point_temperature + solar_radiation + rainfall + snowfall,
             data = train)

# Modelo 2: Variáveis de tempo/data
model2 <- lm(rented_bike_count ~ hour + seasons_Spring + seasons_Summer +
               seasons_Autumn + seasons_Winter + holiday_No_Holiday +
               functioning_day_Yes,
             data = train)

# Modelo 3: Combinação de meteorológicas + tempo/data
model3 <- lm(rented_bike_count ~ temperature + humidity + wind_speed + visibility +
               dew_point_temperature + solar_radiation + rainfall + snowfall +
               hour + seasons_Spring + seasons_Summer + seasons_Autumn +
               seasons_Winter,
             data = train)

# Função RMSE
rmse <- function(true, pred) sqrt(mean((true - pred)^2))

# Previsões e RMSE
predict1 <- predict(model1, test)
predict2 <- predict(model2, test)
predict3 <- predict(model3, test)

cat("RMSE modelo 1 (meteorologia):", rmse(test$rented_bike_count, predict1), "\n")
cat("RMSE modelo 2 (tempo/data):", rmse(test$rented_bike_count, predict2), "\n")
cat("RMSE modelo 3 (combinado):", rmse(test$rented_bike_count, predict3), "\n")

# Guardar modelo 3
saveRDS(model3, "Modelo.rds")
cat("Modelo combinado guardado com sucesso em 'Modelo.rds'\n")




