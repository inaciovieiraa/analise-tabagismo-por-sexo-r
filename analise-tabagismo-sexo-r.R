
#1. Carregando pacote e dados:

library(tidyverse)
dados_fumo <- read.csv("smoking_health_data_final.csv")

#2. Limpeza de dados:

dados_limpos <- dados_fumo %>% 
  
  #Arrumando o sexo:
  
  mutate(sex = str_squish(sex),
         SEXO = case_when(sex == "male" ~ "M",
                          sex == "female" ~ "F")) %>% 
  select(-sex) %>% 
  
  #Tirando NA dos cigarros fumados por dia por fumantes ativos:
  
  filter(!is.na(cigs_per_day)) %>% 
  
  #Separando pressão em sistolica e diastolica e convertendo isso para números:
  separate(col = blood_pressure,
           into = c("pressao_sistolica", "pressao_diastolica"),
           sep = "/") %>% 
  mutate(pressao_sistolica = as.numeric(pressao_sistolica),
         pressao_diastolica = as.numeric(pressao_diastolica))
  
# 3. Calculando e agrupando:

calculo_dados <- dados_limpos %>% 
  
  #Obs: tire a próxima linha para obter os dados da população geral, e não apenas das pessoas que fumam:
  filter(current_smoker == "yes") %>%

  group_by(SEXO) %>% 
  summarise(
    total_pessoas = n(),
    media_colesterol = mean(chol, na.rm = TRUE),
    media_heartrate = mean(heart_rate, na.rm = TRUE),
    media_de_cigarros_por_dia = mean(cigs_per_day, na.rm = TRUE))

# 4. Gráfico de Barras evidenciando a média de cigarros fumados por dia por sexo:

calculo_dados %>% 
  ggplot(aes(x = SEXO, y = media_de_cigarros_por_dia)) +
  geom_col(aes(fill = SEXO), show.legend = FALSE) +
  labs(
    title = "Número de cigarros que cada sexo fuma, em média, por dia!",
    subtitle = "Dados coletados por Md Raihan Kahn (Kaggle.com)",
    x = "SEXO (F = Feminino / M = Masculino)",
    y = "MÉDIA DE CIGARROS FUMADOS POR DIA") +
  geom_text(aes(label = round(media_de_cigarros_por_dia, 2), vjust = -0.3), size = 4.5) +
  theme_minimal()
  
  
