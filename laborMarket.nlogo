extensions [
  csv
  ;ocupacionBN
  r
  ;time
]

breed [people person]

;globals [ dt ]


people-own [
  ; tabla 2.5 de la tesis de Jean
  ; "Valores de las propiedades obtenidas de la base de datos"
  ; Atributos generales
  Clase2; CONDICION, INEGI: Clasificación población ocupada y desocupada; disponible y no disponible
  sex; Sexo, INEGI: Sexo
  CS_P13_1; Escolaridad, INEGI: Pregunta 13 ¿Hasta qué grado aprobó …en la escuela?
  CS_P17; ¿estudia? INEGI: ¿… Asiste actualmente a la escuela?
  eda5c; Edad 5 categorias, INEGI: Clasificación de la población de 15 años y más: Grupo de edad 5 claves

  ; Atributos laborales
  rama_est1; Rama, INEGI: Clasificación de la población ocupada según sector de actividad-Totales
  pos_ocu; Posición en la ocupación, INEGI: Clasificación de la población ocupada por posición en la ocupación
  emp_ppal; Formalidad/Informalidad, INEGI: Clasificación de empleos formales e informales de la primera actividad
	ing7c; Ingreso, INEGI: Clasificación de la población ocupada por nivel de ingreso
  seg_soc; Seguridad social, INEGI: Clasificación de la población ocupada por condición de acceso a instituciones de salud
  sub_o; ¿Subocupación?, INEGI: Población subocupada
  t_tra; Número de empleos, INEGI: Total de trabajos
  dur_est; Jornada, INEGI: Clasificación de la población ocupada por la duración de la jornada

  ; Otros atributos (NIJ = NO INCLUIDA POR JEAN)
  eda; (NIJ), INEGI: Edad (númerica)
  anios_esc; (NIJ), INEGI: Años de escolaridad (numérica)
  e_con; (NIJ), INEGI: Estado conyugal
  c_inac5c; (NIJ), INEGI: Clasificación de la población no económicamente activa no disponible por condición de inactividad
  ingocup; (NIJ), INEGI: Ingreso mensual
]


to setup
  clear-all
  initialize-people
  nets
  ;set dt time:create "2005/03/31"
  reset-ticks
  ; try to initialize the JavaGD plot device
  r:setPlotDevice
end

to initialize-people
    file-close-all
  ;file-open "test_dataset.csv"
  file-open "sdemt_2005t1_30087.csv"

  ;; To skip the header row in the while loop,
  ;  read the header row here to move the cursor
  ;  down to the next line.
  let headings csv:from-row file-read-line
  ;print item 0 headings

  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    ;print data
    create-people 1 [
      ;setxy random-xcor random-ycor
      set shape "person"
			; Atributos Generales
			set sex item 21 data
			set eda item 22 data
			set CS_P13_1 item 28 data
      set CS_P17 item 33 data
			set e_con item 35 data
			set Clase2 item 47 data
      set c_inac5c item 77 data
      set eda5c item 80 data
			set anios_esc item 86 data

      ; Atributos laborales
			set pos_ocu item 49 data
      set seg_soc item 50 data
      set ing7c item 53 data
      set rama_est1 item 58 data
      set dur_est item 60 data
      set sub_o item 70 data			
			set ingocup item 88 data
			set t_tra item 97 data
			set emp_ppal item 98 data
			
      ;set color read-from-string item 1 data
      move-to one-of patches with [not any? people-here ]
    ]
  ]
  file-close-all
end

to go
  ;; stop condition
  ; 60 ticks are equivalent to 15 years
  ; So, simulated period goes from 2005 to 2020
  if ( ticks >= 60 ) [stop]

  ; 1st process
  age
  ; 2nd process
  ; ocupation

  tick
end

to nets
  ; Following lines also works
  r:eval "library(bnlearn)"
  let evalstring (word "netgral <- read.net('" red-ocupacion "')")
  r:eval evalstring
  print "Red Bayesiana de condición de ocupación"
  print r:get "netgral"
  print "cpquery evento = 'NODISPONIBLE', evidencia = 1,1,3"
  print r:get "cpquery(netgral, event = (CONDICION == 'NODISPONIBLE'), evidence = ((SEX == '1') & (CS_P17 == '1') & (CS_P13_1 == '3') ) )"
  ;r:eval "graphviz.plot(netgral)"
end


to age
  if (ticks > 0 and ( ticks mod 4 = 0 ) )[
    ask people [
      set eda ifelse-value ( (eda / 102) ^ 2 < random-float 7)[eda + 1][0]
    ]
  ]
end

;to ocupation
;  ask people with [Clase2 != 1][
;    let prob-ocupation ocupacionBN:get-condicion-prob (word sex "," CS_P17 "," CS_P13_1)
;    if (prob-ocupation > 0.3)[
;      set Clase2 1
;    ]
;  ]
;end


to ocupation
  ask people with [Clase2 != 1][

  ]
end

to plot-age
  histogram [eda] of people
end
@#$#@#$#@
GRAPHICS-WINDOW
272
11
709
449
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
7
10
70
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
98
11
161
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
716
11
1163
161
Age distribution
Age
Freq
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-age"

MONITOR
1071
20
1156
65
Average age
mean [eda] of people
0
1
11

PLOT
1166
11
1522
161
Trend Age
Quarter
Age
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"avg" 1.0 0 -16777216 true "" "plot mean [eda] of people"
"max" 1.0 0 -2674135 true "" "plot max [eda] of people"

BUTTON
7
50
258
83
elige la ruta a la red de ocupación...
set red-ocupacion user-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
8
86
258
165
red-ocupacion
D:/alepa/Dropbox/Research/Unemployment/laborMarket/cond_exp1.net
1
0
String

TEXTBOX
12
168
162
186
Evita usar diagonal invertida
11
4.0
1

@#$#@#$#@
# Overview
## 1 Propósito
* **¿Cuál es el propósito del modelo?** 
Simular el mercado laboral veracruzano a partir de datos de la Encuesta Nacional de Ocupación y Empleo (ENOE).
* **¿Con qué objetivo se ha desarrollado?** 
El objetivo de este trabajo es generar datos artificiales, mediante un sistema multiagente, que nos permita predecir las características de las entidades a observar en periodos de tiempo determinados. 
* **¿Para qué se va a utilizar?** 
Para comparar los resultados de la simulación con los datos reales y así validar la propuesta de simulación con minería de datos.

## 2 Entidades, Variables de estado y escalas
* **¿Qué tipo de entidades conforman el modelo (agentes/individuos, unidades espaciales, medioambiente, colectividades)?** 
Los agentes son instanciados a partir de datos de la ENOE, por lo que representan a la Población Economicaamente Activa (PEA) y Población No Económicamente Activa (PNEA). El grid espacial no tiene significado. Existen modelos gráficos probabilistas, denominadas Redes Bayesianas, que son encapsulados y en los cuales los agentes hacen consultas para guiar su comportamiento.
* **¿Qué variables de estado o atributos internos caracterizan a tales entidades?** 
Los agentes tienen dos grupos de atributos, denominaddos "generales" y "laborales". Las redes bayesianas son encapsulados con estado fijo, es decir, tanto la estructura como los parámetros no se modifican a lo largo de la simulación.
* **¿En qué unidades se expresaran tales variables o atributos?** 
Tanto los atributos generales como laborales, pueden ser variables contínuas y discretas. Como el salario, la edad o la escolaridad. Sin embargo, al hacer la consulta a la red, todas las variables son discretas.
* **¿Cual es la extensión espacial y temporal del modelo?** 
No existe una representación explicita del espacio. En cuanto a la extensión temporal, los datos de entrada corresponden a la ENOE del primer trimestre de 2005 y cada tick de la simulación representa un trimestre, se simularan 60 ticks, que representaran 15 años.
* **¿Con qué nivel de precisión espacial y temporal se realizará la simulación?** 
La precisión temporal es trimestral. En cuanto al espacio, no hay representación explicita.

## 3 Resumen del proceso y su planificación
* **¿Qué entidad hace qué?** 
Los agentes, que representan a la PEA y a la PNEA, cada 4 ticks incrementan su edad en 1 año, y eventualmente realizan consultas a los modelos de red bayesiana. Por su parte, las redes bayesianas, sirven de guía para instanciar los atributos laborales o generales de los agentes que los consultan.
* **¿En qué orden se ejecutan los diferentes procesos?** 
  1. Si han pasado 4 trimestres, se actualiza la edad de los agentes.  
  2. Todos los agentes desocupados encuentran empleo, adquieren las propiedades de su empleo aleatoriamente.  
  3. Se desemplea a agentes ocupados de acuerdo con la tasa publicada por el INEGI en el periodo simulado.
* **¿En qué orden ejecutan distintas entidades un mismo proceso?** 
Los agentes son formados aleatoriamente en una cola, los primeros en la cola ejecutan primero el proceso. 
* **¿Cómo se modeliza el tiempo, mediante saltos discretos o como un continuo temporal en el que suceden tanto procesos continuos como sucesos discretos?** 
Se modela de forma discreta en saltos que representan un trimestre.

# 4 Conceptos de diseño

## Principios fundamentales
* **¿Qué conceptos, teorías, hipótesis teóricas subyacen en el diseño del modelo?** 
 1. La simulación se fundamenta en la representación abstracta de la realidad a través de modelos de redes bayesianas, los cuales "guían" el comportamiento de los agentes.
 2. Se asume que se conoce la tasa de desempleo del periodo a simular.
 3. Se asume que todos los agentes con estado "desocupado" encuentran empleo en un periodo.
 4. Se asume que 1000 agentes son suficientes para representar adecuadamente el mercado laboral del estado de Veracruz. 
 5. Los agentes incrementan su edad cada 4 periodos, pero se asume que no mueren.
* **¿Qué estrategias de modelado subyacen en el mismo diseño?** 
Se utiliza una ruleta, para aleatoriamente seleccionar las propiedades de los agentes, en donde atributos con mayor probabilidad (derivado de la consulta a la red bayesiana) tienen mayor posibilidad de ser elegidos para instanciar al agente. 
* **¿Qué relación guardan estas asunciones con el propósito del estudio?** 
* **¿Cómo se tienen en cuenta en la modelización?**
* **¿Se utilizan en el nivel de los submodelos (como hipótesis microfundamentales) o en el nivel del sistema (como teorías macrodinámicas)?** 
Se utilizan a nivel de sistema como teorías macrodinámicas, ya que no se aporta evidencia en este trabajo sobre el uso de la ruleta a nivel microfundamento.
* **¿Proporcionará el modelo indicios respecto a estos principios fundamentales, como por ejemplo su alcance, su utilidad en escenarios reales, su validación o indicaciones para su modificación?** 
Proporciona indicios sobre como podría implementarse en escenarios reales, pero aún se deben relajar muchos supuestos.
* **¿Utiliza el modelo teorías consolidadas o novedosas?** 
Se utilizan las redes bayesianas, pero no como "guía" principal en el comportamiento de los agentes.

## Emergencia
* **¿Qué resultados son modelados como resultados emergente de rasgos adaptativos o de comportamiento de los individuos?** 
Las tasas de subocupación e informalidad.
* **¿Que resultados del modelo se espera que varíen de forma compleja y tal vez imprevisible ante un cambio de las características particulares de individuos o entorno?** 
Dado que la adquisición de atributos se hace por medio del artificio de la ruleta, pueden existir muchos cambios imprevisibles, incluso si la tabla de probabilidad condicional de la red bayesiana está cargada hacia un atributo.
* **¿Qué resultados del modelo que están ya impuestos por las reglas y por tanto dependen menos de los comportamientos de los individuos?** 
  1. El incremento en la edad.
  2. El cambio de status "desocupado" a "ocupado".
  3. La tasa de desempleo en cada periodo.

## Adaptación
* **¿Qué rasgos adaptativos tienen los individuos?** 
Los agentes pueden adaptan edad, condición de ocupación, jornada laboral, ingreso, rama de actividad, posición en la ocupación, condición de subocupación, su acceso a la seguridad social y su condición de informalidad.
* **¿Qué reglas tienen para tomar decisiones o modificar su comportamiento en respuesta a cambios en sí mismos o en el entrono?** 
 1. Cuando ha transcurrido un año, los agentes actualizan su edad.
 2. Cuando se encuentran "desocupados" pasan a "ocupados", realizan una inferencia a la red bayesiana para obtener las probabilidades de sus propiedades laborales y las cuales eligen mediante ruleta.
 3. La cantidad de agentes a desemplear, se modifica de acuerdo con la tasa de desempleo publicada por el INEGI.
* **¿Estos rasgos intentan incrementar algún tipo de indicador de éxito individual relacionado con sus objetivos (p.e., “desplazate a la posición que disponga de una productividad mayor”, asumiendo que productividad es un indicador de éxito)?** 
No, las deciciones se toman al azar.
* **¿O simplemente los individuos reproducen ciertos comportamientos que se asumen implícitamente como conducentes al éxito o la adaptación (p.e., “desplazate hacia la derecha un 70% del tiempo”)?** 
Si, los agentes tienden a reproducir ciertos comportamientos que se abstraen de la realidad a través de un modelo de redes bayesianas.

## Objetivos
* **¿Qué objetivos persiguen los individuos mediante los procesos de adaptación que rigen sus comportamientos?** 
Los agentes no tienen objetivos en sus procesos de adaptación.
* **¿Cómo se pueden medir tales objetivos, así como su grado de cumplimiento?** 
Los agentes no tienen objetivos.
* **¿Qué criterios usan los agentes individuales para evaluar alternativas cuando tienen que tomar decisiones?** 
Utilizan un ruleta para tomar decisiones.

## Aprendizaje
* **¿Cambian los rasgos adaptativos a lo largo del tiempo como consecuencia de la experiencia?** 
No, los agentes siguen las mismas reglas a lo largo de la simulación.
* **¿Cómo se dan tales cambios?** 
No hay cambios en la adaptación sólo en los estados de algunas variables.
* **¿Se trata de cambios conscientes, incluso planificados, o son simplemente respuestas a un entorno en evolución?** 
No hay cambios en los comportamientos.
* **¿Se dan procesos de co-evolución por influencia mutua entre características individuales y del entorno?** 
Los agentes y las redes bayesianas no cambian, por lo tanto no co-evolucionan.

## Predicción
* **¿Cómo predice un agente las condiciones futuras que experimentará?** 
Los agentes no hacen predicciones, toman decisiones aleatorias ponderadas por las probabilidades de una red bayesiana.
* **¿Cómo influyen tales predicciones sobre los procesos de adaptación y de aprendizaje?** 
No hay predicción y por lo tanto tampoco influencia en la adaptación y el aprendizaje.
* **¿Qué elementos, propios y del entorno, utiliza un agente individual para realizar sus predicciones?** 
Los agentes envían atributos internos como evidencia a una red bayesiana para obtener un conjunto de probabilidades sobre la instanciación de atributos en el siguiente periodo, sin embargo, no predice, utiliza esas probabilidades en una ruleta.
* **¿Qué modelos internos (razonamiento) utilizan los agentes para estimar sus condiciones futuras?** 
Los agentes utilizan una red bayesiana para obtener probabilidades sobre diferentes eventos (atributos) que deberan instanciar en el siguiente periodo. Utilizan esas probabilidades en una ruleta para tomar la decisión.
* **¿Qué modelos utilizan para estimar las consecuencias futuras de sus comportamientos?** 
 1. Utilizan dos modelos de red bayesiana: 
  a. uno sobre su condición de ocupación, 
  b. y otro sobre sus condiciones laborales. 
 2. La ruleta empleada por De Jong<sup>[1]</sup> 
> [1] De Jong, K.A.: Analysis of the behavior of a class of genetic adaptive systems. Tech. Rep. 185, The University of Michigan (1975).

* **¿Qué supuestos tácitos implican tales modelos de razonamiento y racionalidad?** 
 1. Se asume que las redes representan adecuadamente el mercado laboral del estado de Veracruz.
 2. Se asume que la toma de decisiones basada en la ruleta de De Jong es adecuada para simular el mercado laboral del estado de Veracruz.

## Percepción
* **¿Qué variables de estado, internas o del entorno, se asume que perciben los agentes?** 
Los agentes sólo pueden percibir sus propios atributos.
* **¿Qué modelo de medida usan los agentes para tal percepción?** 
Pendiente.
* **¿Qué otros agentes o entidades son percibidas, y en concreto mediante qué atributos?**
Pueden percibir las tablas de probabilidad condicional resultantes de la consulta a la red bayesiana, relacionados con los atributos de condición laboral o de empleo.
* **¿Mantienen los agentes una memoria o mapa a largo plazo de sus percepciones?**
No, los agentes no tienen memoría de sus percepciones.
* **¿Cual es el alcance de las señales que un agente puede percibir, local o global?**
Su alcance es local, ya que no pueden percibir los atributos de otros agentes.
* **¿Si la percepción es a través de una red social, su estructura es impuesta o emergente de la simulación?**
No existe una estructura en la simulación.
* **¿Los mecanismos mediante los que los agentes obtienen información están modelizados explícitamente, o se asumen como dados?**
Se trata de un mecanismo modelado explicitamente.

## Interacción
* **¿Qué tipos de interacciones se asumen como relevantes entre los agentes?**
No existe interacción entre los agentes. Sólo entre cada agente con la red bayesiana.
* **¿Se trata de interacciones directas, en las que los encuentros entre agentes influyen sobre los mismos?**
Entre los agentes no hay interacción. Del encuentro entre entre el agente y la red bayesiana surge una influencia parcial sobre la toma de decisión del agente.
* **¿Hay interacciones indirectas, como en caso de competir por un recurso intermedio?**
No existen interacciones indirectas.
* **¿Si las interacciones implican comunicación, cómo se han modelizado tales procesos comunicativos?**
En la interacción agente-red bayesiana, los agentes envían como evidencia sus atributos a la red bayesiana, la cual regresa al agente la(s) probabilidad(es) de ocurrencia de el(los) evento(s) consultados.

## Aleatoriedad
* **¿Qué procesos se han modelado asumiendo que son, total o parcialmente, aleatorios?**
La Ruleta de De Jong, para decidir entre probabilidades de ocurrencia de atributos es un proceso que es totalmente aleatorio.
* **¿Se utiliza la aleatoriedad para generar variabilidad en procesos para los que no se considera importante modelizar sus causas?**
Se utiliza aleatoriedad en los resultados de cada consulta hecha a la red bayesiana.
* **¿Se utiliza aleatoriedad para generar sucesos o comportamientos que ocurren con una frecuencia específica conocida?**
Se utiliza aleatoriedad, a través de la ruleta, en cada periodo.

## Colectivos
* **¿Los individuos forman o pertenecen a agregaciones que influyen y son influidas por los mismos individuos?**
No existe formación de colectivos o agrupaciones entre los agentes.
* **¿Cómo se representan tales colectividades?**
No aplica.
* **¿Tales colectivos son una propiedad emergente del comportamiento de los individuos?**
No aplica.
* **¿Son los colectivos simplemente definiciones del modelador, es decir, conjuntos de entidades con sus propios atributos y comportamientos?**
No aplica.

## Observación
* **¿Qué datos se generan y recopilan a partir de la simulación a efectos de análisis?**
Principalmente las tasas de subocupación y de informalidad laboral.
* **¿Cómo son recopilados tales datos, y en qué momento o momentos?**
En cada periodo se almacenan los atributos de los agentes.
* **¿Se utiliza la totalidad de los datos generados, o sólo una muestra a imitación de lo que sucede habitualmente en un estudio empírico?**
Se utiliza la totalidad de los datos generados.



# Detalles

## 5 Inicialización
* **¿Cuál es el estado inicial del modelo, esto es, en el momento t=0 de la ejecución de la simulación?**
Al momento inicial, los agentes adquieren sus atributos directamente de la Encuesta Nacional de Ocupación y Empleo.
* **¿Cuántas entidades forman la sociedad virtual inicialmente, y qué valores, exactos o como distribución aleatoria, tienen las variables de estado de las entidades?**
Son 1,000 agentes instanciados directamente de una muestra para el estado de Veracruz de la Encuesta Nacional de Ocupación y Empleo.
* **¿Es siempre idéntica o puede variar entre diferentes ejecuciones de la simulación?**
Siempre es idéntica.
* **¿La inicialización corresponde a un estado del mundo real, esto es, está empíricamente calibrada (data-driven), o los valores son arbitrarios?**
Corresponde a un estado del mundo real.
* **¿Si se trata de una situación inicial experimental, cómo corresponden los valores arbitrarios a hipótesis concretas a contrastar?**
No aplica.

## 6 Datos de entrada
**¿Utiliza el modelo datos de fuentes externas (ficheros de datos, u otros modelos) para representar procesos que varían en el tiempo durante la simulación?**
Si, se utiliza un muestra de tamaño 1000, correspondientes a datos del estado de Veracruz tomados de la Encuesta Nacional de Ocupación y Empleo del primer trimestre de 2010, especificamente del cuestionario sociodemográfico. También se utiliza información real sobre las tasas de desempleo de los siguientes periodos.

## 7 Submodelos
* **¿Qué modelos representan, con detalle, los procesos listados en el apartado de procesos y planificación?**
 1. La red bayesiana de condición de ocupación, consta de 4 variables relacionadas de la siguiente manera:
![BN_ocup](file:BN_cond_ocup.png)
 2. La red bayesiana de condiciones laborales, consta de 12 variables relacionadas de la siguiente manera:
![BN_labs](file:BN_cond_labs.png)
 3. Al inicio, los atributos de los agentes son instanciados con una muestra de la ENOE, "representativa" del estado de Veracruz.
 4. Si han pasasdo 4 trimestres, se actualiza la edad de los agentes.
 5. Si un agente supera los 15 años, deja de ser considerado "menor".
 6. Todo agente con condición de ocupación "desocupada", cambiará su estatus a "ocupada".
 7. Todo agente que ha cambiado su condición a "ocupada", hará una consulta a la red bayesiana de condiciones laborales, enviando sus atributos generales (sexo, escolaridad, edad y ¿estudia?), para obtener Tablas de Probabilidad Condicional (TPC) del resto de las variables (propiedades laborales).
 8. Cuando un agente deja de ser menor, debe cambiar su condición, envia sus atributos (sexo, escolaridad, ¿estudia?) a la red bayesiana de condición de ocupación, para obtener la TPC de la variable condición.
 9. Si condición cambia de "menor" a "ocupado", en ese mismo periodo realiza una consulta a la red bayesiana de condiciones laborales.
 10. Con la información de las TPC, se realiza una selección aleatoria mediante ruleta de cada uno de los estatos de las variables consultadas (de condición o laborales).
 11. Se desemplea a agentes ocupados aleatoriamente de acuerdo con la tasa publicada por el INEGI en el periodo simulado.
* **¿Cuales son los parámetros, dimensiones y valores de referencia de cada modelo?**
 1. Las redes bayesianas fueron seleccionadas por "observación", con el algoritmo de búsqueda Hill Climber, iniciando con una red vacia, empleando la manta de Markov, con un máximo de 10000 padres, Minimum Description Length (MDL) como métrica de evaluación y se permite revertir arcos.
 2. El poder predictivo de la red bayesiana de condición de ocupación es de 65.73% (bajo), mientras que para la red bayesiana de condiciones laborales es de 94.11% (alto).
 3. Se inicia con 1000 agentes, se asume que son una muestra "representativa" del estado de Veracruz.
 3. Los valores de referencia  para los atributos de los 1000 agentes son obtenidos directamente del conjunto muestral de datos de la ENOE. Nota: No se especifica el criterio para determinar la representatividad de la muestra.
* **¿Qué ecuaciones o algoritmos permiten representar cada modelo?**
Las acciones de los agentes de representan a través de reglas de comportamiento.
* **¿Cómo se han diseñado o seleccionado tales modelos?**
Se asume que el mecanismo aleatorio de la ruleta para la toma decisiones de los agentes representa adecuadamente la realidad.
* **¿De qué otros sistemas se han “extraido” o “inspirado” los modelos para su uso actual?**
Se emplea el enfoque guiado por datos.
* **¿Cómo se justifica la verificación y la validez de cada modelo utilizado?**
 1. No existe evidencia contundente sobre la validación de la correcta especificación de los modelos de red bayesiana.
 2. Se comparan los datos artificiales sobre la tasa de subocupación y tasa de ocupación en el sector informal, con los datos reales para establecer la validez de la simulación.
 3. También se compara la tasa de desocupación generada por la simulación con la real, pero existe una alta posibilidad de que esto sea así por el submodelo 11.
* **¿Qué referencias y literatura relevante se puede aportar para cada submodelo, respecto a su implementación independiente, contraste, calibración y análisis?**
No existe literatura sobre la correcta especificación de los modelos de red bayesiana.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
