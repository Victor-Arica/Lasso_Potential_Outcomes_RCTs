rm(list = ls())
setwd("C:\\Users\\Julio\\Desktop\\R\\Output")

# Parte 3: Potential Outcomes and RCTs

# Cargar librerías necesarias
library(tidyverse)
library(glmnet)
library(knitr)
library(broom)

# Establecer semilla para reproducibilidad
set.seed(2024)

# 3.1 SIMULACIÓN DE DATOS

#Simular dataset con n=1000 individuos
n <- 1000

# Generar covariables
X1 <- rnorm(n, mean = 0, sd = 1)          # Continua: estandarizada
X2 <- rnorm(n, mean = 2, sd = 1.5)        # Continua: escala diferente  
X3 <- rbinom(n, size = 1, prob = 0.4)     # Binaria: indicador educación (40% tienen educación)
X4 <- rbinom(n, size = 1, prob = 0.3)     # Binaria: indicador urbano (30% viven en área urbana)

# Asignación de tratamiento (aleatorizada)
D <- rbinom(n, size = 1, prob = 0.5)

# Término de error
epsilon <- rnorm(n, mean = 0, sd = 1)

# Variable de resultado según la especificación dada:
# Y = 2D + 0.5X₁ - 0.3X₂ + 0.2X₃ + ε
# NOTA: X₄ intencionalmente NO tiene efecto (para probar selección de LASSO)
Y <- 2*D + 0.5*X1 - 0.3*X2 + 0.2*X3 + epsilon

# Crear data.frame como se especifica
rct_data <- data.frame(
  Y = Y,
  D = D,
  X1 = X1,
  X2 = X2,
  X3 = X3,
  X4 = X4
)

# Guardar los datos simulados
save(rct_data, file = "rct_data.RData")
load("rct_data.RData")  # El objeto mantiene su nombre original

# Mostrar estadísticas descriptivas
summary_table <- rct_data %>%
  summarise(
    Y_media = mean(Y), Y_sd = sd(Y),
    X1_media = mean(X1), X1_sd = sd(X1),
    X2_media = mean(X2), X2_sd = sd(X2),
    D_prop = mean(D),
    X3_prop = mean(X3),
    X4_prop = mean(X4),
    .groups = "drop"
  )

print(kable(summary_table, digits = 3, caption = "Estadísticas Resumen del Dataset Simulado"))

#Verificación de equilibrio (balance check)
#Comparando medias de covariables entre tratamiento y control

# Realizar pruebas de balance usando t.test
balance_results <- data.frame(
  Variable = c("X1", "X2", "X3", "X4"),
  Media_Control = numeric(4),
  Media_Tratamiento = numeric(4),
  Diferencia = numeric(4),
  Valor_P = numeric(4),
  Balanceado = character(4),
  stringsAsFactors = FALSE
)

# Variables a evaluar
variables <- c("X1", "X2", "X3", "X4")

for(i in 1:length(variables)) {
  var <- variables[i]
  
  # Extraer valores por grupo
  valores_control <- rct_data[[var]][rct_data$D == 0]
  valores_tratamiento <- rct_data[[var]][rct_data$D == 1]
  
  # Calcular medias
  media_control <- mean(valores_control)
  media_tratamiento <- mean(valores_tratamiento)
  
  # Realizar prueba t
  test_resultado <- t.test(valores_tratamiento, valores_control)
  
  # Almacenar resultados
  balance_results[i, "Media_Control"] <- media_control
  balance_results[i, "Media_Tratamiento"] <- media_tratamiento
  balance_results[i, "Diferencia"] <- media_tratamiento - media_control
  balance_results[i, "Valor_P"] <- test_resultado$p.value
  balance_results[i, "Balanceado"] <- ifelse(test_resultado$p.value > 0.05, "Sí", "No")
}

print(kable(balance_results, digits = 4, caption = "Resultados de Verificación de Balance"))

# Evaluación general del balance
variables_desbalanceadas <- sum(balance_results$Valor_P < 0.05)
tamaño_tratamiento <- sum(rct_data$D)
tamaño_control <- sum(1 - rct_data$D)

cat(sprintf("• Variables con desbalance significativo (p < 0.05): %d de 4\n", variables_desbalanceadas))
cat(sprintf("• Tamaño grupo tratamiento: %d individuos (%.1f%%)\n", tamaño_tratamiento, 100*mean(rct_data$D)))
cat(sprintf("• Tamaño grupo control: %d individuos (%.1f%%)\n", tamaño_control, 100*(1-mean(rct_data$D))))

if(variables_desbalanceadas == 0) {
} else if(variables_desbalanceadas <= 1) {
} else {
}


#3.2 Estimando el ATE

#3.2.1) Regresión simple Y ~ D
modelo_simple <- lm(Y ~ D, data = rct_data)
resumen_simple <- summary(modelo_simple)

ate_simple <- coef(modelo_simple)["D"]
se_simple <- resumen_simple$coefficients["D", "Std. Error"]
ci_simple <- confint(modelo_simple)["D", ]
t_stat_simple <- resumen_simple$coefficients["D", "t value"]
p_value_simple <- resumen_simple$coefficients["D", "Pr(>|t|)"]

#Resultados de la reg simple
cat(sprintf("• Estimación ATE: %.4f\n", ate_simple))
cat(sprintf("• Error estándar: %.4f\n", se_simple))
cat(sprintf("• IC 95%%: [%.4f, %.4f]\n", ci_simple[1], ci_simple[2]))
cat(sprintf("• Estadístico t: %.3f\n", t_stat_simple))
cat(sprintf("• Valor p: %.6f\n", p_value_simple))
cat(sprintf("• Significativo al 5%%: %s\n", ifelse(p_value_simple < 0.05, "Sí", "No")))

#3.2.2) Regresión completa Y ~ D + X1 + X2 + X3 + X4

modelo_completo <- lm(Y ~ D + X1 + X2 + X3 + X4, data = rct_data)
resumen_completo <- summary(modelo_completo)

ate_completo <- coef(modelo_completo)["D"]
se_completo <- resumen_completo$coefficients["D", "Std. Error"]
ci_completo <- confint(modelo_completo)["D", ]
r2_completo <- resumen_completo$r.squared

#Resultados de la reg completa
cat(sprintf("• Estimación ATE: %.4f\n", ate_completo))
cat(sprintf("• Error estándar: %.4f\n", se_completo))
cat(sprintf("• IC 95%%: [%.4f, %.4f]\n", ci_completo[1], ci_completo[2]))
cat(sprintf("• R-cuadrado: %.4f\n", r2_completo))

# Mostrar todos los coeficientes estimados
coef_tabla <- broom::tidy(modelo_completo)
print(kable(coef_tabla, digits = 4, caption = "Coeficientes del Modelo Completo"))

#Comparar las dos estimaciones

tabla_comparacion <- data.frame(
  Modelo = c("Simple (Y ~ D)", "Completo (Y ~ D + X₁ + X₂ + X₃ + X₄)"),
  Estimacion_ATE = c(ate_simple, ate_completo),
  Error_Estandar = c(se_simple, se_completo),
  IC_Inferior = c(ci_simple[1], ci_completo[1]),
  IC_Superior = c(ci_simple[2], ci_completo[2]),
  ATE_Verdadero = c(2.0, 2.0),
  Sesgo = c(ate_simple - 2.0, ate_completo - 2.0)
)

print(kable(tabla_comparacion, digits = 4, caption = "Comparación de Estimaciones ATE"))

#3.2.3) Análisis de las diferencias
cambio_ate <- abs(ate_completo - ate_simple)
cambio_se <- se_completo - se_simple
ganancia_precision <- ifelse(se_completo < se_simple, 
                             (se_simple^2 - se_completo^2) / se_simple^2 * 100, 
                             0)

#Cambia el ATE?
cat(sprintf("• Diferencia absoluta: %.4f\n", cambio_ate))
cat(sprintf("• Cambio porcentual: %.2f%%\n", cambio_ate/abs(ate_simple) * 100))
if(cambio_ate < 0.01) {
  cat("• Conclusión: El ATE prácticamente NO cambia (diferencia mínima)\n")
} else {
  cat("• Conclusión: Hay un cambio notable en el ATE\n")
}

#Que sucede con los errores estándar?
cat(sprintf("• Error estándar simple: %.4f\n", se_simple))
cat(sprintf("• Error estándar completo: %.4f\n", se_completo))
cat(sprintf("• Cambio: %.4f\n", cambio_se))

#3.3) Lasso y la selección de variables

#3.3.1) Preparar matriz de covariables (EXCLUYENDO el tratamiento D)
X_covariables <- as.matrix(rct_data[, c("X1", "X2", "X3", "X4")])
Y_resultado <- rct_data$Y

# Validación cruzada para LASSO
cv_lasso <- cv.glmnet(X_covariables, Y_resultado, alpha = 1, nfolds = 10)

# Extraer valores óptimos de lambda
lambda_min <- cv_lasso$lambda.min
lambda_1se <- cv_lasso$lambda.1se

#Resultados de la validacion cruzada
cat(sprintf("• λ óptimo (mínimo CV error): %.6f\n", lambda_min))
cat(sprintf("• λ 1SE (regla de 1 error estándar): %.6f\n", lambda_1se))

# Ajustar LASSO con lambda óptimo
modelo_lasso <- glmnet(X_covariables, Y_resultado, alpha = 1, lambda = lambda_min)
coef_lasso <- coef(modelo_lasso)

#Coeficientes lasso con lambda minimo
print(as.matrix(coef_lasso))

# Identificar variables seleccionadas
coef_no_cero <- coef_lasso[-1, 1]  # Excluir intercepto
variables_seleccionadas <- names(coef_no_cero)[abs(coef_no_cero) > 1e-8]

cat(sprintf("\nVariables seleccionadas por LASSO en λ_min: %s\n", 
            ifelse(length(variables_seleccionadas) > 0, 
                   paste(variables_seleccionadas, collapse = ", "), 
                   "Ninguna")))

# Verificar si X4 fue correctamente excluida
if("X4" %in% variables_seleccionadas) {
  cat("⚠ X₄ fue seleccionada (aunque no tiene efecto real)\n")
} else {
  cat("✓ X₄ fue correctamente excluida (no tiene efecto real)\n")
}

# También mostrar resultados con lambda 1SE para comparación
modelo_lasso_1se <- glmnet(X_covariables, Y_resultado, alpha = 1, lambda = lambda_1se)
coef_lasso_1se <- coef(modelo_lasso_1se)
coef_no_cero_1se <- coef_lasso_1se[-1, 1]
variables_seleccionadas_1se <- names(coef_no_cero_1se)[abs(coef_no_cero_1se) > 1e-8]

cat(sprintf("Variables seleccionadas por LASSO en λ_1SE: %s\n", 
            ifelse(length(variables_seleccionadas_1se) > 0, 
                   paste(variables_seleccionadas_1se, collapse = ", "), 
                   "Ninguna")))

#3.3.2) Re-estimar ATE con covariables seleccionadas por LASSO

# Usar las variables seleccionadas con lambda_min
if(length(variables_seleccionadas) > 0) {
  cat(sprintf("Re-estimando ATE incluyendo las variables seleccionadas: %s\n", 
              paste(variables_seleccionadas, collapse = ", ")))
  
  # Crear fórmula con variables seleccionadas
  formula_lasso <- as.formula(paste("Y ~ D +", paste(variables_seleccionadas, collapse = " + ")))
  
  modelo_lasso_ate <- lm(formula_lasso, data = rct_data)
  resumen_lasso <- summary(modelo_lasso_ate)
  
  ate_lasso <- coef(modelo_lasso_ate)["D"]
  se_lasso <- resumen_lasso$coefficients["D", "Std. Error"]
  ci_lasso <- confint(modelo_lasso_ate)["D", ]
  r2_lasso <- resumen_lasso$r.squared
  
} else {
  cat("LASSO no seleccionó ninguna variable, usando modelo simple Y ~ D\n")
  ate_lasso <- ate_simple
  se_lasso <- se_simple
  ci_lasso <- ci_simple
  r2_lasso <- summary(modelo_simple)$r.squared
}

cat("\nResultados del modelo con selección LASSO:\n")
cat(sprintf("• Estimación ATE: %.4f\n", ate_lasso))
cat(sprintf("• Error estándar: %.4f\n", se_lasso))
cat(sprintf("• IC 95%%: [%.4f, %.4f]\n", ci_lasso[1], ci_lasso[2]))
cat(sprintf("• R-cuadrado: %.4f\n", r2_lasso))

if(length(variables_seleccionadas) > 0) {
  cat("\nCoeficientes del modelo final:\n")
  coef_tabla_lasso <- broom::tidy(modelo_lasso_ate)
  print(kable(coef_tabla_lasso, digits = 4, caption = "Modelo con Variables Seleccionadas por LASSO"))
}

#3.3.3) Comparar con estimaciones de la Parte 3.2

tabla_comparacion_final <- data.frame(
  Metodo = c("Simple (Y ~ D)", 
             "Completo (Y ~ D + X₁ + X₂ + X₃ + X₄)", 
             "LASSO Seleccionado"),
  Estimacion_ATE = c(ate_simple, ate_completo, ate_lasso),
  Error_Estandar = c(se_simple, se_completo, se_lasso),
  IC_Inferior = c(ci_simple[1], ci_completo[1], ci_lasso[1]),
  IC_Superior = c(ci_simple[2], ci_completo[2], ci_lasso[2]),
  Variables_Usadas = c("Ninguna", 
                       "Todas (X₁, X₂, X₃, X₄)", 
                       ifelse(length(variables_seleccionadas) > 0, 
                              paste(variables_seleccionadas, collapse = ", "), 
                              "Ninguna")),
  ATE_Verdadero = c(2.0, 2.0, 2.0),
  Sesgo = c(ate_simple - 2.0, ate_completo - 2.0, ate_lasso - 2.0)
)

print(kable(tabla_comparacion_final, digits = 4, caption = "Comparación Final de Métodos"))

# Análisis de precisión
precisions <- c(1/se_simple^2, 1/se_completo^2, 1/se_lasso^2)
best_precision_idx <- which.max(precisions)
methods <- c("Simple", "Completo", "LASSO")

#Cual metodo dió mayor precisión?
cat(sprintf("• Método con mayor precisión: %s (menor error estándar: %.4f)\n", 
            methods[best_precision_idx], 
            c(se_simple, se_completo, se_lasso)[best_precision_idx])) 

# Análisis de sesgo
sesgos <- abs(c(ate_simple, ate_completo, ate_lasso) - 2.0)
best_accuracy_idx <- which.min(sesgos)
cat(sprintf("• Método con menor sesgo: %s (sesgo absoluto: %.4f)\n", 
            methods[best_accuracy_idx], sesgos[best_accuracy_idx]))
Pre_3_3 <-"¿Qué ventajas podría tener LASSO en este contexto?
1. SELECCIÓN AUTOMÁTICA: Identifica automáticamente variables relevantes
2. REDUCCIÓN DE OVERFITTING: Evita incluir variables irrelevantes como X₄
3. PARSIMONIA: Produce modelos más simples e interpretables
4. MANEJO DE ALTA DIMENSIONALIDAD: Útil cuando p >> n
5. ESTABILIDAD: Menos sensible a variables irrelevantes
"
writeLines(Pre_3_3, con = "Pre_3_3.md")

#Análisis de la exclusion de x4
if("X4" %in% variables_seleccionadas) {
  cat("\n NOTA: En este caso, LASSO incluyó X₄ que no tiene efecto real.\n")
  cat("   Esto puede ocurrir debido a correlaciones espurias en la muestra.\n")
} else {
  cat("\n✓ ÉXITO: LASSO correctamente excluyó X₄ que no tiene efecto real.\n")
  cat("   Esto demuestra la capacidad de LASSO para la selección de variables.\n")
}

# Guardar resultados finales
write.csv(balance_results, "balance_check_results.csv", row.names = FALSE)
write.csv(tabla_comparacion_final, "ate_comparison_final.csv", row.names = FALSE)
