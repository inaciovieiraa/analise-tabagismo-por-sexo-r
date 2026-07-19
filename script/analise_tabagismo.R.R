#1. Carregando pacote e dados:

library(tidyverse)
dados_fumo <- read.csv("C:/Users/conta/OneDrive/Área de Trabalho/smoking_health_data_final.csv")

#2. Limpeza dos dados: 

dados_limpos <- dados_fumo |> 
  mutate(
    
#2.1_ Corrigindo possíveis espaços em branco que atrapalhem a análise e padronizando os dados sobre o sexo dos indivíduos:
    SEXO = str_squish(sex),
    SEXO = str_to_upper(SEXO),
    SEXO = case_when(SEXO == "MALE" ~ "M",
                     SEXO == "FEMALE" ~"F"),
    
#2.2_ Corrigindo possíveis espaços em branco que atrapalhem a análise e padronizando os dados sobre indivíduos fumantes e não fumantes:    
    FUMANTE = str_squish(current_smoker),
    FUMANTE = str_to_upper(FUMANTE),
    FUMANTE = case_when(FUMANTE == "YES" ~ "SIM",
                        FUMANTE == "NO" ~ "NÃO"),

#2.3_ Por garantia, confirmando se todos os dados da frequência cardíaca são numéricos:
    FREQ_CARDIACA = as.numeric(heart_rate)) |> 

#2.4_ Separando a pressão arterial em "diastólico" e "sistólico" e convertendo para algarismos numéricos:
  
  separate(col = blood_pressure, 
           into = c("sistólico", "diastólico"), 
           sep = "/", 
           convert = TRUE) |> 
  mutate(
    SISTÓLICO = as.numeric(sistólico),
    DIASTÓLICO = as.numeric(diastólico),
    
#2.5_ Tratando NAs dos não fumantes e criando categorias de Carga Tabágica:
    CIGARROS_DIA = case_when(
      FUMANTE == "NÃO" ~ 0, 
      TRUE ~ cigs_per_day),
      
      CARGA_TABAGICA = case_when(
      CIGARROS_DIA == 0 ~ "0. Não Fumante",
      CIGARROS_DIA >= 1 & CIGARROS_DIA <= 9 ~ "1. Leve (1 a 9/dia)",
      CIGARROS_DIA >= 10 & CIGARROS_DIA <= 19 ~ "2. Moderado (10 a 19/dia)",
      CIGARROS_DIA >= 20 ~ "3. Pesado (20+/dia)"),
    
#2.6_ Criando faixas etárias para controle epidemiológico:
    IDADE = as.numeric(age),
    FAIXA_ETARIA = case_when(
      IDADE <= 30 ~ "1. Até 30 anos",
      IDADE >= 31 & IDADE <= 45 ~ "2. 31 a 45 anos",
      IDADE >= 46 & IDADE <= 60 ~ "3. 46 a 60 anos",
      IDADE > 60 ~ "4. Mais de 60 anos")) |> 
  
#2.7_ CANCELANDO (deletando) os fumantes que responderam NA:
  filter(!is.na(CIGARROS_DIA)) |> 
  
#2.8_ Selecionando apenas as colunas limpas, padronizadas em português e ordenadas:
  select(SEXO, IDADE, FAIXA_ETARIA, FUMANTE, CIGARROS_DIA, CARGA_TABAGICA, 
         FREQ_CARDIACA, SISTÓLICO, DIASTÓLICO, COLESTEROL = chol)

#3. Exportando a base limpa para a criação de dashboard no Excel:
write_excel_csv2(dados_limpos, "dados_fumo_tratados_excel.csv")

# 4. Gerando o gráfico de comparação do consumo médio por sexo (usando a base limpa):

dados_limpos |>
  filter(FUMANTE == "SIM") |> 
  group_by(SEXO) |>
  summarise(media_cigarros = mean(CIGARROS_DIA, na.rm = TRUE)) |>
  
  ggplot(aes(x = SEXO, y = media_cigarros, fill = SEXO)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = round(media_cigarros, 2)), vjust = -0.5) +
  labs(title = "CONSUMO MÉDIO DE CIGARROS POR SEXO",
       subtitle = "Homens fumantes apresentam consumo diário superior às mulheres.",
       x = "SEXO",
       y = "MÉDIA DE CIGARROS / DIA") +
  theme_minimal()


    

