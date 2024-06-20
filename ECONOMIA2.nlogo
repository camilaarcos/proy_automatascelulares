globals [
  neighborhood-size  ; Tamaño de cada barrio en parches
  neighborhood-colors ; Lista de colores de los barrios
  subsidy-trigger-level ; Nivel de ingreso mínimo para activar el subsidio
  subsidy-amount       ; Cantidad de incremento de ingreso debido al subsidio
]
; patches = celda
patches-own [
  income-level ; nivel de ingresos del parche
  neighborhood ; Identificador del barrio al que pertenece el parche
  has-shopping-center  ; Indica si el parche tiene un centro comercial
  has-hospital; inidica si el parche tiene un hospital
  has-olla  ; Indica si el parche tiene una olla
  has-non-potable-water-area ; Indica si el parche tiene zona de agua no potable
  age; edad del parche
  education-level ; nivel educacion del parche
  services-access    ; accesibilidad a servicios
]
to setup ; inicializa la aplicación
  clear-all ; Limpia todo el mundo y reinicia las variables

  ; Verificar que num-neighborhoods sea al menos 1
  if num-neighborhoods < 1 [
    user-message "El número de barrios debe ser al menos 1."
    stop
  ]

  ; Calcula el mismo tamaño de barrio para todos, teniendo en cuenta el número de los mismos y el tamaño total del mundo
  set neighborhood-size max (list 1 floor (sqrt (count patches / num-neighborhoods)))

  ; Inicializa la lista de colores para los barrios
  set neighborhood-colors [grey blue yellow]

  set subsidy-trigger-level 0.5  ; Nivel de ingreso mínimo para activar el subsidio
  set subsidy-amount 0.1        ; Cantidad de incremento de ingreso debido al subsidio

  ; Asignar parches a los barrios y establecer el color predominante del barrio
  let remaining-patches patches
  let neighborhood-id 0
  ;mientras hay parches continua el bucle
  while [any? remaining-patches] [
    ;selecciona un numero de parches.. La cantidad seleccionada se calcula dividiendo el número de parches restantes entre el número de barrios restantes redondeado hacia abajo.
    let selected-patches n-of (floor (count remaining-patches / (num-neighborhoods - neighborhood-id))) remaining-patches
    ;para cada parche seleccionado se le asigna
    ask selected-patches [
      set neighborhood neighborhood-id ; identificador
      set income-level random-float 1.0 ; nivel de ingreso
      set has-shopping-center false ; no tiene centro comercial
      set has-olla false ; no tiene olla
      set has-hospital false ; no tiene hospital
      set has-non-potable-water-area false ; no tiene zona de agua no potable

      ; Asignar edad y nivel educativo aleatorios
      set age random 100  ; Edad entre 0 y 99
      set education-level random 6  ; Nivel educativo entre 0 y 5
      set services-access random-float 1.0 ; acceso a servicio aleatorio entre 0.0 y 1.0

      ; Asignar color según el nivel de ingreso
      ;para saber el porcentaje se divide entre los 3
      if income-level < 0.34 [ ;pobre
        set pcolor grey
      ]
      if income-level >= 0.34 and income-level < 0.67 [ ;medio
        set pcolor blue
      ]
      if income-level >= 0.67 [ ; rico
        set pcolor yellow
      ]
    ]
    ; Actualiza los parches restantes y el identificador de barrio
    set remaining-patches (patch-set remaining-patches with [not member? self selected-patches]) ; elimina los parches que han sido seleccionados
    set neighborhood-id (neighborhood-id + 1)
  ]

  ; Asignar centros comerciales de manera aleatoria y de color verde
  let shopping-centers-patches n-of num-shopping-centers patches
  ask shopping-centers-patches [
    set has-shopping-center true
    set pcolor green
  ]

  ; Asignar ollas de manera aleatoria y de color negro
  let ollas-patches n-of num-ollas patches
  ask ollas-patches [
    set has-olla true
    set pcolor black
  ]

  ; Asignar hospitales de manera aleatoria y de color rojo
  let hospital-patches n-of num-hospitals patches
  ask hospital-patches [
    set has-hospital true
    set pcolor red
  ]

  ; Asignar zona de agua no potable de manera aleatoria y de color rosa
  let non-potable-water-area-patches n-of num-non-potable-water-area patches
  ask non-potable-water-area-patches [
    set has-non-potable-water-area true
    set pcolor pink
  ]

  draw-borders ; dibuja las fronteras de los barrios

  reset-ticks ; reinicia el contador de ticks
end


to draw-borders
  ask patches [
    if (pxcor mod neighborhood-size = 0 or pycor mod neighborhood-size = 0) [ ;dibuja las fronteras de los barrios de color negro
      set pcolor black
    ]
  ]
end

;; REGLAS

;;Media ponderada
to transition-rule-1
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let avg-income mean [income-level] of neighbors

    ; Ajuste del nivel de ingreso según el promedio de los vecinos
    if avg-income > income-level [
      set income-level min list (income-level + 0.001) 1.0 ; Incremento lento del ingreso
    ]
    if avg-income < income-level [
      set income-level max list (income-level - 0.001) 0.0 ; Decremento lento del ingreso
    ]
    ; Efecto adicional de centros comerciales y ollas
    if any? neighbors with [has-shopping-center] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un centro comercial cercano
    ]
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un hospital cercano
    ]
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una olla cercana
    ]
    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una zona de agua no potable cercana
    ]
    ; Actualiza el color del parche según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end

;; MAX vecinos
to transition-rule-2
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let max-income max [income-level] of neighbors

    ; Ajuste del nivel de ingreso hacia el máximo de los vecinos
    set income-level income-level + 0.001 * (max-income - income-level)

    ; Efecto adicional de centros comerciales y ollas
    if any? neighbors with [has-shopping-center] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un centro comercial cercano
    ]
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un hospital cercano
    ]
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una olla cercana
    ]
    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una zona de agua no potable cercana
    ]
    ; Actualiza el color del parche según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end

;; MIN vecinos
to transition-rule-3
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let min-income min [income-level] of neighbors

    ; Ajuste del nivel de ingreso hacia el mínimo de los vecinos
    set income-level income-level - 0.001 * (income-level - min-income)

    ; Efecto adicional de centros comerciales y ollas
    if any? neighbors with [has-shopping-center] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un centro comercial cercano
    ]
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level + 0.01) 1.0 ; Incremento rápido si hay un hospital cercano
    ]
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una olla cercana
    ]
    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.01) 0.0 ; Decremento rápido si hay una zona de agua no potable cercana
    ]
    ; Actualizar color según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end
;; CLASE MEDIA si hay un centro comercial
to transition-rule-4
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let age-factor (1 - age / 100)
    let education-factor (education-level / 5)
     let avg-income mean [income-level] of neighbors
    if avg-income > income-level [
      set income-level min list (income-level + 0.01 ) 1.0 ; Incrementar nivel de ingreso lentamente
    ]
    if avg-income < income-level [
      set income-level max list (income-level - 0.01 ) 0.0 ; Decrementar nivel de ingreso lentamente
    ]
    ; Efecto potente de los hospitales
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level + 0.01 ) 1.0 ;Aumenta significativamente si hay un hospital
    ]
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.01 ) 0.0 ; decrementa los que esten cerca de una olla
    ]
    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.01 ) 0.0 ; Decremento si hay una zona de agua no potable cercana
    ]
    if any? neighbors with [has-shopping-center]
    [    set income-level 0.5                               ; los vecinos del centro comercial se quedan en clase media
    ]

    ; Actualizar color según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end
;; incrementa si hay hospital y centros comerciales presentes
to transition-rule-5
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let avg-income mean [income-level] of neighbors
    let age-factor (1 - age / 100)
    let education-factor (education-level / 5)

    if avg-income > income-level [
      set income-level min list (income-level + 0.01 ) 1.0 ; Incrementar nivel de ingreso lentamente
    ]
    ; Efecto significativo de los hospitales
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level +  0.1 ) 1.0 ; incrementa medio
    ]

    ; Efecto significativo de los centros comerciales
    if any? neighbors with [has-shopping-center] [
      set income-level min list (income-level +  0.1 ) 1.0 ; incrementa medio
    ]

    ; Efecto significativo de las ollas
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.1 ) 0.0 ;decrementa en nivel medio
    ]

    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.1 ) 0.0 ; Decremento en nivel medio
    ]

    ; Efecto combinado de hospitales y centros comerciales si ambos están presentes
    if any? neighbors with [has-hospital] and any? neighbors with [has-shopping-center] [
      set income-level min list (income-level + 0.2 ) 1.0
    ]

    ; Actualizar color según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end
;; edad y nivel educativo
to transition-rule-6
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    let avg-income mean [income-level] of neighbors
    let max-income max [income-level] of neighbors
    let min-income min [income-level] of neighbors

    ; Factores de ajuste basados en la edad y el nivel educativo
    let age-factor (1 - age / 100)  ; Factor de ajuste basado en la edad (entre 0 y 1)
    let education-factor (education-level / 5)  ; Factor de ajuste basado en el nivel educativo (entre 0 y 1)

    ; Ajuste del nivel de ingreso basado en la edad y el nivel educativo
    if avg-income > income-level [
      set income-level min list (income-level + 0.001 * age-factor * education-factor) 1.0 ; Incremento lento del ingreso
    ]
    if avg-income < income-level [
      set income-level max list (income-level - 0.001 * age-factor * education-factor) 0.0 ; Decremento lento del ingreso
    ]
    ; Ajuste del nivel de ingreso hacia el máximo de los vecinos
    set income-level income-level + 0.001 * (max-income - income-level) * age-factor * education-factor

    ; Ajuste del nivel de ingreso hacia el mínimo de los vecinos
    set income-level income-level - 0.001 * (income-level - min-income) * age-factor * education-factor

    ; Efecto adicional de centros comerciales y ollas
    if any? neighbors with [has-shopping-center] [
      set income-level min list (income-level + 0.01 * age-factor * education-factor) 1.0 ; Incremento rápido si hay un centro comercial cercano
    ]
    if any? neighbors with [has-hospital] [
      set income-level min list (income-level + 0.01 * age-factor * education-factor) 1.0 ; Incremento rápido si hay un hospital cercano
    ]
    if any? neighbors with [has-olla] [
      set income-level max list (income-level - 0.01 * age-factor * education-factor) 0.0 ; Decremento rápido si hay una olla cercana
    ]
    if any? neighbors with [has-non-potable-water-area] [
      set income-level max list (income-level - 0.01 * age-factor * education-factor) 0.0 ; Decremento rápido si hay una zona de agua no potable cercana
    ]

    ; Actualizar color según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end
;; subsidio
to transition-rule-7
  ask patches with [not has-shopping-center and not has-olla and not has-hospital and not has-non-potable-water-area] [
    ; Verificar si el parche cumple con las condiciones para recibir subsidio
    if income-level < subsidy-trigger-level and services-access > 0.5 [
      ; Aplicar el efecto de subsidio
      set income-level min list (income-level + subsidy-amount) 1.0 ; Incremento del ingreso debido al subsidio
    ]
    ; Actualizar color según el nivel de ingreso
    if income-level < 0.34 [
      set pcolor grey
    ]
    if income-level >= 0.34 and income-level < 0.67 [
      set pcolor blue
    ]
    if income-level >= 0.67 [
      set pcolor yellow
    ]
  ]
end

to go
  if selected-rule = "MEDIA PONDERADA" [
    transition-rule-1
  ]
  if selected-rule = "MAXIMO VECINOS" [
    transition-rule-2
  ]
  if selected-rule = "MINIMO VECINOS" [
    transition-rule-3
  ]
  if selected-rule = "CLASE MEDIA" [
    transition-rule-4
  ]
  if selected-rule = "HOSPITAL Y CENTRO COMERCIAL JUNTOS" [
    transition-rule-5
  ]
  if selected-rule = "EDAD Y EDUCACION" [
    transition-rule-6
  ]
  if selected-rule = "SUBSIDIO" [
    transition-rule-7
  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
591
10
1505
565
-1
-1
6.0
1
6
1
1
1
0
0
0
1
-75
75
-45
45
0
0
1
ticks
30.0

SLIDER
54
91
226
124
num-neighborhoods
num-neighborhoods
0
15
4.0
1
1
NIL
HORIZONTAL

BUTTON
55
135
118
168
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
149
135
212
168
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
57
39
329
84
selected-rule
selected-rule
"MEDIA PONDERADA" "MAXIMO VECINOS" "MINIMO VECINOS" "CLASE MEDIA" "HOSPITAL Y CENTRO COMERCIAL JUNTOS" "EDAD Y EDUCACION" "SUBSIDIO"
0

BUTTON
150
177
213
210
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

SLIDER
51
232
224
265
num-shopping-centers
num-shopping-centers
0
50
10.0
5
1
NIL
HORIZONTAL

SLIDER
51
329
226
362
num-ollas
num-ollas
0
50
35.0
5
1
NIL
HORIZONTAL

SLIDER
53
276
225
309
num-hospitals
num-hospitals
2
10
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
387
163
537
181
NIL
10
0.0
1

TEXTBOX
470
262
620
322
Gris: Pobre\nAzul: Medio\nAmarillo: Rico
16
96.0
1

TEXTBOX
244
259
410
354
Verde: Centro comercial\nRojo: Hospital\nNegro: Olla\nRosado: Zona de agua no potable
15
95.0
1

TEXTBOX
29
444
349
489
- Centro comerciales y hospitales incrementan\n- Ollas y zonas de agua no potable disminuyen
12
0.0
1

SLIDER
51
385
247
418
num-non-potable-water-area
num-non-potable-water-area
0
35
35.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.4.0
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
