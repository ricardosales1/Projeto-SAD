# --- EDA COM VISUALIZAÇÃO: Seoul Bike Sharing ---

# 0 - Carregar pacotes necessários
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)

# 1 - Carregar o conjunto de dados limpo (antes de normalização)
seoul_bike <- read_csv("dataset/clean/clean_seoul_bike.csv")

# 2 - Reformular DATE como data
seoul_bike <- seoul_bike %>%
  mutate(date = as.Date(date, format = "%d/%m/%Y"))

# 3 - Converter HOUR para variável categórica ordenada
seoul_bike <- seoul_bike %>%
  mutate(hour = factor(hour, levels = 0:23, ordered = TRUE))

# 4 - Resumo do conjunto de dados
summary(seoul_bike)

# 5 - Calcular número de feriados (holiday_No Holiday == 0)
num_feriados <- sum(seoul_bike$`holiday_No Holiday` == 0)
print(paste("Número de feriados:", num_feriados))

# 6 - Percentagem de registos que são feriados
pct_feriados <- mean(seoul_bike$`holiday_No Holiday` == 0) * 100
print(paste("Percentagem de registos em feriados:", round(pct_feriados, 2), "%"))

# 7 - Número esperado de registos (1 ano × 365 dias × 24 horas)
registos_esperados <- 365 * 24
print(paste("Registos esperados:", registos_esperados))

# 8 - Quantos registos são dias de funcionamento
registos_funcionamento <- sum(seoul_bike$`functioning_day_Yes` == 1)
print(paste("Registos com funcionamento:", registos_funcionamento))

# 9 - Precipitação total e neve por estação
precipitacao_neve <- seoul_bike %>%
  mutate(season = case_when(
    seasons_Spring == 1 ~ "Spring",
    seasons_Summer == 1 ~ "Summer",
    seasons_Winter == 1 ~ "Winter",
    TRUE ~ "Autumn"
  )) %>%
  group_by(season) %>%
  summarize(
    total_rainfall = sum(rainfall, na.rm = TRUE),
    total_snowfall = sum(snowfall, na.rm = TRUE)
  )
print(precipitacao_neve)

# 10 - Gráfico: RENTED_BIKE_COUNT vs DATE
ggplot(seoul_bike, aes(x = date, y = rented_bike_count)) +
  geom_point(alpha = 0.5) +
  labs(title = "Rented Bike Count ao longo do tempo", x = "Data", y = "Nº de bicicletas alugadas")

# 11 - Gráfico: Rented Bike Count vs Date com Hour como cor
ggplot(seoul_bike, aes(x = date, y = rented_bike_count, color = hour)) +
  geom_point(alpha = 0.5) +
  labs(title = "Rented Bike Count vs Date por Hour", x = "Data", y = "Nº de bicicletas alugadas")

# 12 - Histograma com curva de densidade do kernel
ggplot(seoul_bike, aes(x = rented_bike_count)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", alpha = 0.7) +
  geom_density(color = "blue", size = 1) +
  labs(title = "Distribuição do número de bicicletas alugadas", x = "Bicicletas alugadas", y = "Densidade")

# 13 - Dispersão: RENTED_BIKE_COUNT vs TEMPERATURA por estação (cor = hour)
ggplot(seoul_bike, aes(x = temperature, y = rented_bike_count, color = hour)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ case_when(
    seasons_Spring == 1 ~ "Spring",
    seasons_Summer == 1 ~ "Summer",
    seasons_Winter == 1 ~ "Winter",
    TRUE ~ "Autumn"
  )) +
  labs(title = "Correlação entre temperatura e aluguer por estação")

# 14 - Boxplots: RENTED_BIKE_COUNT vs HOUR agrupado por estação
ggplot(seoul_bike, aes(x = hour, y = rented_bike_count)) +
  geom_boxplot() +
  facet_wrap(~ case_when(
    seasons_Spring == 1 ~ "Spring",
    seasons_Summer == 1 ~ "Summer",
    seasons_Winter == 1 ~ "Winter",
    TRUE ~ "Autumn"
  )) +
  labs(title = "Distribuição de aluguer por hora e estação", x = "Hora", y = "Bicicletas alugadas")

# 15 - Precipitação e neve por dia
diario <- seoul_bike %>%
  group_by(date) %>%
  summarize(
    total_rainfall = sum(rainfall, na.rm = TRUE),
    total_snowfall = sum(snowfall, na.rm = TRUE)
  )
print(head(diario))

# 16 - Quantos dias tiveram queda de neve
dias_com_neve <- sum(diario$total_snowfall > 0)
print(paste("Dias com queda de neve:", dias_com_neve))
