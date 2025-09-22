# TG2: Modelos Lineales de Alta Dimensión, LASSO, Resultados Potenciales y RCTs
rm(list = ls())
setwd("C:\\Users\\Julio\\Desktop\\R\\Input")
#install.packages("ggplot")
library(readxl)
library(dplyr)
library(ggplot2)
library(glmnet)
set.seed(123)

#REGRESIÓN LASSO
Base_Lasso <- read_excel("Districtwise_literacy_rates.xlsx")
Base_Lasso <- na.omit(Base_Lasso) #Eliminar las bases sin obs
setwd("C:\\Users\\Julio\\Desktop\\R\\Output")

# Histograma alfabetización femenina
ggplot(Base_Lasso, aes(x = `FEMALE_LIT`)) +
  geom_histogram(bins = 20, fill = "purple", alpha = 0.7) +
  labs(title = "Distribución alfabetización femenina")

# Histograma alfabetización masculina
ggplot(Base_Lasso, aes(x = `MALE_LIT`)) +
  geom_histogram(bins = 20, fill = "blue", alpha = 0.7) +
  labs(title = "Distribución alfabetización masculina")


##Estimate a low-dimensional specification

# Definir y (variable objetivo) y X (predictoras)
y <- Base_Lasso$`FEMALE_LIT`
X <- Base_Lasso %>% 
  select(-`FEMALE_LIT`, -DISTRICTS) %>% 
  select_if(is.numeric) %>%  # Solo columnas numéricas
  as.matrix()

# Train-test split (70-30)
n <- nrow(X)
train_index <- sample(1:n, size = 0.7*n)
X_train <- X[train_index, ]
X_test  <- X[-train_index, ]
y_train <- y[train_index]
y_test  <- y[-train_index]

# LASSO baja dimensión
cv_lasso <- cv.glmnet(X_train, y_train, alpha = 1, nfolds = 10)

# Predicciones
y_pred <- predict(cv_lasso, s = "lambda.min", newx = X_test)

# R²
R2_low <- cor(y_test, y_pred[,1])^2
R2_low #R-squared del conjunto de prueba




##Estimate a high-dimensional specification

# Crear características de alta dimensión con términos de interacción y cuadráticos
create_high_dim_features <- function(X_matrix) {
  X_df <- as.data.frame(X_matrix)
  X_expanded <- X_df
  
  # Términos cuadráticos para las primeras 10 variables
  var_names <- colnames(X_df)
  top_vars <- var_names[1:min(10, length(var_names))]
  
  for(var in top_vars) {
    X_expanded[[paste0(var, "_sq")]] <- X_df[[var]]^2
  }
  
  # Términos de interacción entre las 6 variables principales
  top_6 <- var_names[1:min(6, length(var_names))]
  
  for(i in 1:(length(top_6)-1)) {
    for(j in (i+1):length(top_6)) {
      var1 <- top_6[i]
      var2 <- top_6[j]
      interaction_name <- paste0(var1, "_x_", var2)
      X_expanded[[interaction_name]] <- X_df[[var1]] * X_df[[var2]]
    }
  }
  
  return(as.matrix(X_expanded))
}

# Aplicar expansión a conjuntos de entrenamiento y prueba
X_train_high <- create_high_dim_features(X_train)
X_test_high <- create_high_dim_features(X_test)

cat(sprintf("Características originales: %d\n", ncol(X_train)))
cat(sprintf("Características expandidas: %d\n", ncol(X_train_high)))

# LASSO alta dimensión
cv_lasso_high <- cv.glmnet(X_train_high, y_train, alpha = 1, nfolds = 10)

# Predicciones
y_pred_high <- predict(cv_lasso_high, s = "lambda.min", newx = X_test_high)

# R²
R2_high <- cor(y_test, y_pred_high[,1])^2
R2_high #R-squared de alta dimension

##Trayectoria de los lambdas

# Para λ que van desde 10,000 hasta 0.001
lambda_seq <- 10^seq(log10(10000), log10(0.001), length.out = 100)

# Ajustar LASSO con toda la secuencia de lambda usando características de alta dimensión
lasso_path <- glmnet(X_train_high, y_train, alpha = 1, lambda = lambda_seq)

# Extraer número de coeficientes no cero para cada lambda
coef_matrix <- coef(lasso_path)[-1, ]  # Excluir intercepto
nonzero_coefs <- apply(coef_matrix, 2, function(x) sum(abs(x) > 1e-8))

# Crear data frame para el gráfico
path_data <- data.frame(
  lambda = lambda_seq,
  log_lambda = log10(lambda_seq),
  nonzero_coefs = nonzero_coefs
)

# Gráfico del camino de regularización
ggplot(path_data, aes(x = lambda, y = nonzero_coefs)) +
  geom_line(color = "steelblue", size = 1.0) +
  geom_point(color = "steelblue", size = 1.2) +
  scale_x_log10() +
  labs(
    title = "Trayectoria LASSO: número de variables seleccionadas vs λ",
    x = "Lambda (λ, escala log)",
    y = "Número de coeficientes ≠ 0"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    panel.grid.major = element_line(color = "gray80"),
    panel.grid.minor = element_line(color = "gray90")
  )

ggsave("lasso_path.png", width = 10, height = 6)

# Análisis del camino de regularizacion
cat(sprintf("Total de características disponibles: %d\n", ncol(X_train_high)))
cat(sprintf("Máximo coeficientes no cero (λ = %.3f): %d\n", min(lambda_seq), max(nonzero_coefs)))
cat(sprintf("Mínimo coeficientes no cero (λ = %.0f): %d\n", max(lambda_seq), min(nonzero_coefs)))

# Comentario sobre el resultado
Pre_2 <-"A medida que lambda decrece, más coeficientes entran en el modelo
Con lambda alto, el modelo es muy sparse (pocos predictores).
Con lambda bajo, el modelo incluye más variables.
La trayectoria muestra el trade-off entre sesgo y varianza"
writeLines(Pre_2, con = "Pre_2.md")

# Resumen final
cat(sprintf("R² Modelo Baja Dimensión: %.4f\n", R2_low))
cat(sprintf("R² Modelo Alta Dimensión: %.4f\n", R2_high))
