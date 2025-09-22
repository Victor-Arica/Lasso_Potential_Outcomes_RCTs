
Lamba muy elevado:

En este caso ocurre que la penalización sobre los tamaños de los coeficientes es extrema. 
Esto hace que todos los coeficientes se reduzcan exactamente a cero. El modelo predice la media de
la variable de resultado para todas las observaciones, lo que da lugar a un sesgo elevado
y un error de entrenamiento elevado (subajuste).
El error de prueba también es elevado porque el modelo no logra captar
ningún patrón en los datos debido a lasimplificación excesiva.


Lambda muy pequeño:
Aquí ocurre lo contario, la penalización se vuelve insignificante.
La estimación de Lasso se aproxima a la estimación de mínimos cuadrados ordinarios (OLS).
El modelo puede incluir muchos coeficientes, incluidos los de variables irrelevantes,
lo que da lugar a una alta varianza (sobreajuste). El error de entrenamiento será muy bajo,
pero es probable que el error de prueba sea alto porque el modelo se ajusta al ruido de los datos de entrenamiento.
Dicho de forma sencilla, <<aprende de memoria>> por lo cual no puede generalizar sus predicciones.


