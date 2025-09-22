# TG2: Modelos Lineales de Alta Dimensión, LASSO, Resultados Potenciales y RCTs
rm(list = ls())
setwd("C:\\Users\\Julio\\Desktop\\R\\Output")

# PARTE 1: COMENTARIOS (3 puntos)

# 1.1) Comportamiento de LASSO con λ muy grande y muy pequeño

Pre_1_1 <- "
Lamba muy elevado:

En este caso ocurre que la penalización sobre los tamaños de los coeficientes es extrema. 
Esto hace que todos los coeficientes se reduzcan exactamente a cero. El modelo predice la media de
la variable de resultado para todas las observaciones, lo que da lugar a un sesgo elevado
y un error de entrenamiento elevado (subajuste).
El error de prueba también es elevado porque el modelo no logra captar
ningún patrón en los datos debido a la simplificación excesiva.


Lambda muy pequeño:
Aquí ocurre lo contario, la penalización se vuelve insignificante.
La estimación de Lasso se aproxima a la estimación de mínimos cuadrados ordinarios (OLS).
El modelo puede incluir muchos coeficientes, incluidos los de variables irrelevantes,
lo que da lugar a una alta varianza (sobreajuste). El error de entrenamiento será muy bajo,
pero es probable que el error de prueba sea alto porque el modelo se ajusta al ruido de los datos de entrenamiento.
Dicho de forma sencilla, <<aprende de memoria>> por lo cual no puede generalizar sus predicciones.

"

writeLines(Pre_1_1, con = "Pre_1_1.md")

  
# 1,2) Explicación de validación cruzada

Pre_1_2 <- "1.2 Validación cruzada en Machine Learning:
La validación cruzada es una técnica de remuestreo que divide los datos en subconjuntos
para entrenamiento y validación para evaluar el rendimiento del modelo.

Es útil porque proporciona una estimación no sesgada del rendimiento del modelo en datos no vistos,
además permite la selección de hiperparámetros (selección óptima de λ en LASSO).
También reduce el overfitting al probar en múltiples conjuntos de validación.
Finalmente, puede ayudar en la selección y comparación de modelos.

Ahora, imaginemos que queremos realizar una validación cruzada:
Paso 1: Dividimos aleatoriamente los datos en K grupos iguales
Paso 2: Para cada grupo k (k = 1, 2, ..., K):
     - Usaremos grupo k como conjunto de validación
     - Luego usaremos los K-1 grupos anteriores como conjuntos de entrenamiento
     - Con el modelo ya entrenado, calculamos el error de validación
Paso 3: Promediamos los K errores de validación y determinamos la forma óptima del modelo
para su correcta aplicación.
"
writeLines(Pre_1_2, con = "Pre_1_2.md")




