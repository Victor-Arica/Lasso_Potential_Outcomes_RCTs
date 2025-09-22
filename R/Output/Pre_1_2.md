1.2 Validación cruzada en Machine Learning:
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

