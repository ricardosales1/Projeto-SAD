# 🚲 Projeto SAD – Previsão de Partilha de Bicicletas com Dados Meteorológicos

Este repositório contém o trabalho desenvolvido para o projeto final da unidade curricular **Sistemas de Apoio à Decisão** da Universidade Autónoma de Lisboa (UAL), ano letivo **2024/2025**.

## 🎯 Objetivo

Desenvolver um sistema de apoio à decisão que preveja a procura por partilha de bicicletas com base em dados meteorológicos. O sistema utiliza dados reais de várias fontes (incluindo APIs e scraping) e culmina num painel interativo construído em **R Shiny**.

---

## 📁 Estrutura do Projeto

```
ProjetoSAD/
├── dataset/
│   ├── raw/                # Dados brutos recolhidos (CSV)
│   └── clean/              # Dados limpos após disputa
├── Analise.R               # Códigos de análise estatística
├── Coleta.R                # Recolha de dados via API e scraping
├── Disputa.R               # Disputa de dados (limpeza e transformação)
├── EDA.R                   # Análise exploratória de dados
├── Regressão.R             # Modelos de regressão
├── Main.R                  # Painel interativo
├── Modelo.rds              # Modelo de regressão treinado
├── ProjetoSAD.Rproj        # Projeto RStudio
└── README.md               # Este ficheiro
```



---

## 📦 Tecnologias e Bibliotecas

- Linguagem: **R**
- IDE: **RStudio / Posit Cloud**
- Visualização: `ggplot2`, `plotly`, `shiny`
- Manipulação de dados: `dplyr`, `tidyr`, `stringr`, `lubridate`
- Modelação: `tidymodels`, `caret`
- APIs: `httr`, `jsonlite`

---

## 🛠️ Como Executar

1. Clona o repositório:
   ```bash
   git clone https://github.com/ricardosales1/Projeto-SAD.git
   cd Projeto-SAD

2. Abrir o R ou RStudio e instalar as dependências:
   ```bash
   install.packages(c("shiny", "dplyr", "ggplot2", "tidymodels", "lubridate", "httr", "jsonlite", "readr"))

3. Para correr o painel interativo:
   ```bash
   shiny::runApp("Main.r")

---

## 📊 Resultados
O sistema desenvolvido permite:

Visualizar dados meteorológicos e a procura por bicicletas em várias cidades

Prever a procura de bicicletas com base em condições climáticas

Apoiar decisões estratégicas para dimensionamento de frotas

Oferecer uma interface interativa via Shiny App


---

## 🔗 Ligações úteis

- [OpenWeather API](https://openweathermap.org/api)  
- [Wikipedia: Global Bike Sharing Systems](https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems)  
- [Posit Cloud (RStudio Cloud)](https://posit.cloud)
