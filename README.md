# proy_automatascelulares

 INTEGRANTES 

Maria Camila Arcos

Edinson Elvira

Aldemar Vivas


INSTRUCCIONES 

1- Abrir el proyecto en NetLogo 6.4.0

2- Para ver el funcionamiento de los automatas celulares hay que comprender las diferentes caracteristicas.
  - Debe seleccionar la regla que desee implementar en el selected-rule
  - Debe seleccionar el número de barrios (debe ser mayor a 1, si selecciona 0 este no lo dejará realizar el ejercicio)
  - Debe seleccionar la cantidad de centros comerciales, hospitales, ollas y zonas de agua no potable para el ejercicio ( aqui no hay conflicto si elije 0)
  - Para inicializar presiona setup y de allí puede correr el ejercicio manualmente con el go de arriba o de manera continua con el go de abajo
  - Al estar corriendo continuamente el ejercicio el botón de go queda en color oscuro... para detener el ejercicio se debe volver a presionar el botón o el quedará realizando ticks así no se vea reflejado en el gráfico

3- Para entender mas sobre las reglas implementadas, tener en cuenta:
  - 1: MEDIA PONDERADA: Ajusta el nivel de ingreso según el promedio de vecinos
  - 2: MAX VECINOS: Ajusta el nivel de ingresos hacia el maximo del vecino
  - 3: MIN VECINOS: Ajusta el nivel de ingresos hacia el minimo del vecino
  - 4: CLASE MEDIA: Ajusta el nivel de ingresos hacia nivel medio si hay centro comercial cerca
  - 5: HOSPITAL Y CENTRO COMERCIAL JUNTOS: Ajusta el nivel maximo si hay presencia de hospital y centro comercial entre los vecinos
  - 6: EDAD Y EDUCACION: Ajusta el nivel de ingreso basado en la edad y educacion (aleatorios)
  - 7: SUBSIDIO: Ajusta el nivel de ingresado basado en las condiciones de nivel bajo y acceso al servicio

NOTA: para pasar de una a regla a otra (o editar las cantidades) no es necesario hacer setup, se podría hacer si su deseo es iniciar de 0 pero si desea ver el comportamiento del resultado de una regla a otra, lo puede hacer simplemente dando de nuevo en el botón go.
  
