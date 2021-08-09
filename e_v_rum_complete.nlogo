globals [
  percent-similar-eth
  percent-similar-val
]

patches-own [
  systemic_utility
]


to setup
  clear-all
  ask patches [set pcolor white
    if random 100 < density [sprout 1
      [
        ifelse random 100 < %majority
      [set color blue
        set shape ifelse-value (random 100 < %liberal_maj) ["circle"]["square"]          ; attributes of agents
      ]

      [set color orange
        set shape ifelse-value (random 100 < %liberal_min) ["circle"]["square"]
      ]
      ]
    ]
  ]
  update-globals
  reset-ticks
end


to go
  move-turtles       ; relocation decision of turtles
  update-globals
tick
end


to move-turtles          ; here the relocation decision, with the beta distribution

  ask  turtles [

    let beta-ie ifelse-value (beta_distribution = "global")
    [ifelse-value (shape = "square") [dominant][
      ifelse-value (color = blue) [
      ifelse-value (lib_maj) [dominant] [secondary]
      ][ ifelse-value (lib_min) [dominant] [secondary]]
      ]
    ]
     [ifelse-value (beta_distribution = "by-value")
      [ifelse-value (shape = "square") [con_eth][
        ifelse-value (color = blue) [
        ifelse-value (lib_maj) [lib_val] [lib_eth]
        ][ifelse-value (lib_min) [lib_val] [lib_eth]]
      ]]

      [ifelse-value (shape = "square") [eth_con_maj][
        ifelse-value (color = blue) [
        ifelse-value (lib_maj) [val_lib_maj][eth_lib_maj]
        ][ifelse-value (lib_min) [val_lib_min] [eth_lib_min]]
      ]]
    ]

     let beta-iv ifelse-value (beta_distribution = "global")
    [ifelse-value (shape = "square") [
      ifelse-value (color = blue) [
      ifelse-value (con_maj) [dominant][secondary]
      ][ifelse-value (con_min) [dominant][secondary]]
    ][dominant]
    ]
    [ifelse-value (beta_distribution = "by-value")
      [ifelse-value (shape = "square") [
        ifelse-value (color = blue) [
        ifelse-value (con_maj) [con_eth][con_val]
        ][ifelse-value (con_min) [con_eth][con_val]]
      ][lib_val]
      ]

        [ifelse-value (shape = "square") [
        ifelse-value (color =  blue)[
          ifelse-value (con_maj) [eth_con_maj][val_con_maj]][
            ifelse-value (con_min) [eth_con_min][val_con_min]]

          ][ifelse-value (color = blue) [val_lib_maj][val_lib_min]]
        ]
    ]



   let color-myself color
   let shape-myself shape
   let alternative one-of patches with [not any? turtles-here]   ; one empty cell is selected as alternative
   let trial random-float 1.00  ; random number to compare to probability to move to alternative

    let options (patch-set patch-here alternative)   ; the basket choice made of current patch and alternative: at this point, it is just to not rewrite utility attribution for
                                                     ; current patch and alternative

    ask options [

      let xe count (turtles-on neighbors) with [color = color-myself]
      let xv count (turtles-on neighbors) with [ shape = shape-myself]

      let n count (turtles-on neighbors)

      let uti-eth  utility xe n    ; value utility and ethnic utility of each option
      let uti-val  utility xv n

      set systemic_utility (beta-ie * uti-eth) + (beta-iv * uti-val) ; just to simplify and not repeat for each option
    ]

    let proba (1 / (1 + exp([systemic_utility] of patch-here - [systemic_utility] of alternative))) ; probability as logistic function. Kenneth Train (2009) p.3 shows how this is the simplification of
                                                                                                  ; logit (exp(beta*U)/Sum(exp(beta*U)) for 2 options (as probability to move to alternative)
                                                                                                  ; (https://eml.berkeley.edu/books/choice2nd/Ch03_p34-75.pdf)

    if trial <  proba [move-to alternative] ; if probability calculated is higher than trial number [0,1], then the agent relocates  to alternative

  ]

end


to-report utility [sim tot]  ; utility function: sim = number similar (neighborhood moore); tot = total number agents in Moore distance

 report ifelse-value (tot = 0) [0]     ; utility 0 for not any turtle on neighbor
   [ precision (sim / tot) 3 ]        ; utility is computed as fraction (1 is max)

 end

to update-globals
  let similar-eth sum [ count (turtles-on neighbors) with [color = [color] of myself] ] of turtles
  let similar-val sum [ count (turtles-on neighbors) with [shape = [shape] of myself] ] of turtles
  let total-neighbors sum [ count (turtles-on neighbors)  ] of turtles
  set percent-similar-eth (similar-eth / total-neighbors)
  set percent-similar-val (similar-val / total-neighbors)
end
@#$#@#$#@
GRAPHICS-WINDOW
327
10
802
486
-1
-1
9.16
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
117
10
215
43
density
density
0
99
70.0
1
1
NIL
HORIZONTAL

SLIDER
218
11
320
44
%majority
%majority
50
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
668
491
731
524
setup
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
735
491
798
524
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
118
47
215
80
%liberal_maj
%liberal_maj
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
219
48
318
81
%liberal_min
%liberal_min
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
463
489
527
534
% lib maj
count turtles with [shape = \"circle\" and color = blue] / count turtles
2
1
11

MONITOR
396
490
461
535
% con maj
count turtles with [shape = \"square\" and color = blue] / count turtles
2
1
11

MONITOR
598
489
662
534
% lib maj
count turtles with [shape = \"circle\" and color = orange] / count turtles
2
1
11

MONITOR
530
489
595
534
% con min
count turtles with [shape = \"square\" and color = orange] / count turtles
2
1
11

MONITOR
330
490
392
535
%lib pop
count turtles with [shape = \"circle\"] / count turtles
2
1
11

SLIDER
121
376
219
409
eth_con_maj
eth_con_maj
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
121
553
213
586
val_lib_maj
val_lib_maj
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
120
418
217
451
eth_lib_maj
eth_lib_maj
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
122
513
214
546
val_con_maj
val_con_maj
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
224
376
319
409
eth_con_min
eth_con_min
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
224
420
319
453
eth_lib_min
eth_lib_min
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
220
554
315
587
val_lib_min
val_lib_min
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
221
514
315
547
val_con_min
val_con_min
0
20
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
164
359
311
377
distribution beta_ethnic
11
0.0
1

TEXTBOX
169
494
308
512
distribution beta_value
11
0.0
1

TEXTBOX
109
370
124
454
↓\n↓\n↓\n↓\n↓\n↓
10
0.0
1

TEXTBOX
78
391
110
426
value group
10
0.0
1

TEXTBOX
121
455
252
487
→→→→→→→→→→→\n         ethnic group
10
0.0
1

TEXTBOX
111
505
126
589
↓\n↓\n↓\n↓\n↓\n↓
10
0.0
1

TEXTBOX
81
531
115
563
value group
10
0.0
1

TEXTBOX
124
587
251
621
→→→→→→→→→→→\n         ethnic group
10
0.0
1

SLIDER
118
210
210
243
dominant
dominant
0
20
0.0
1
1
NIL
HORIZONTAL

CHOOSER
10
115
102
160
beta_distribution
beta_distribution
"global" "by-value" "type-group"
2

SLIDER
117
269
209
302
con_eth
con_eth
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
118
305
210
338
lib_eth
lib_eth
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
218
305
310
338
con_val
con_val
0
20
0.0
1
1
NIL
HORIZONTAL

SLIDER
218
270
310
303
lib_val
lib_val
0
20
0.0
1
1
NIL
HORIZONTAL

SWITCH
125
149
215
182
lib_maj
lib_maj
1
1
-1000

SWITCH
220
150
310
183
lib_min
lib_min
1
1
-1000

SWITCH
218
112
308
145
con_min
con_min
1
1
-1000

SWITCH
125
111
215
144
con_maj
con_maj
1
1
-1000

SLIDER
220
211
312
244
secondary
secondary
0
20
0.0
1
1
NIL
HORIZONTAL

PLOT
812
26
1088
201
conservative local
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = blue] / 8"

PLOT
1088
26
1342
201
conservative minority
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\"[\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\"[\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = \"square\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\"  and color = orange] / 8"

PLOT
812
202
1087
371
liberal local
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = blue]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = blue] / 8"

PLOT
1088
204
1340
372
liberal minority
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"ethnic" 1.0 0 -5825686 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]\n]\nif visualize = \"spatial clustering\" [\nplot mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"value" 1.0 0 -10899396 true "" "if visualize = \"exposure\" [\nplot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and color = orange]\n]\nif visualize = \"spatial sorting\" [\nplot mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = \"circle\" and count (turtles-on neighbors) >= 1]\n]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\"  and color = orange] / 8"

CHOOSER
1013
390
1154
435
visualize
visualize
"exposure" "spatial clustering"
0

TEXTBOX
117
92
325
110
Secondary preference = dominant preference
10
0.0
1

TEXTBOX
12
10
101
55
Initialization demographics
11
0.0
1

TEXTBOX
20
215
87
250
beta global distribution
11
0.0
1

TEXTBOX
13
281
98
330
beta value-orientation distribution
11
0.0
1

TEXTBOX
14
374
69
420
beta group-type distribution
11
0.0
1

TEXTBOX
9
192
360
210
------------------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

TEXTBOX
13
251
319
269
--------------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

TEXTBOX
15
346
320
364
--------------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

@#$#@#$#@
Model for experiments reproduction and repository archive.
Experiments are set in Tools > BehaviorSpace

# What changes: 

Beta parameter in the relocation choice can be distributed either globally, depending on value-orientation or group-type (crossing ethnicity and value-orientation). Secondary and dominant preference can be tuned independently or the secondary preference being set equal to dominant preference. The individual behavior of agents and dynamics do not change:

Conservatives: 
DOMINANT preference: ethnic similarity
SECONDARY preference: value similarity

Liberals:
DOMINANT preference: value similarity
SECONDARY preference: ethnic similarity

Beta distribution with chooser "beta_distribution":

* global: all agents hold same level of dominant or secondary preference (what is the dominant/secondary preference depends on the agent's type)

* by-value: level of dominant and secondary preference is distributed by agents' orientation, ignoring ethnic membership

* type-group: level of dominant and secondary preference is distributed independently for  each of the 8 group-type of agents due to crossing ethnicity and value orientation


Choosers "con_maj", "lib_maj", "con_min", "lib_min" set ON: Secondary preference has the same level of tunable dominant preference

To understand parameters:

* ethnicity of agents:  maj = majority, min = minority
* orientation of agents: lib = liberals, con = conservatives
* similarity preference: eth = ethnic, val = value

# VISUALIZATION

Each plot reports ethnic segregation, value segregation and neighborhood density of specific group-type. For ethnic segregation and value segregation, chooser "visualize":
* exposure index
* spatial clustering index. Spatial clustering computation slows down the simulation
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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="bsl_dom_secNO" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_dom_sec" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_dom_sec_circle" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_dom_sec_square" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_dom_sec_htmp" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <steppedValueSet variable="secondary" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_value_con_lib" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="con_eth" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
      <value value="1"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_value_lib_con" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
      <value value="1"/>
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="lib_val" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_lib" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="lib_val" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_con" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="con_eth" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_bsl_secNO" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_bsl_sec" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_libmj_mn" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="val_lib_maj" first="0" step="1" last="15"/>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
      <value value="1"/>
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_libmn_mj" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
      <value value="1"/>
      <value value="15"/>
    </enumeratedValueSet>
    <steppedValueSet variable="val_lib_min" first="0" step="1" last="15"/>
  </experiment>
  <experiment name="asym_dislib" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%liberal_min" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_dislib_libmajL" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%liberal_min" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_dislib_libminL" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%liberal_min" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_et_bsl" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_et_mj" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_et_mn" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;global&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="dominant" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_dislib_et_mj" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%liberal_min" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="asym_dislib_et_mn" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%majority" first="50" step="10" last="90"/>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="%liberal_min" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;type-group&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bsl_htmp2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [color = [color] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "circle" and color = blue]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and shape = "square" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) &gt;= 1 and  shape = "circle" and color = orange]</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "square"  and color = orange] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = blue] / 8</metric>
    <metric>mean [count (turtles-on neighbors)] of turtles with [shape = "circle"  and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors))  /  ((count turtles with [color = [color] of myself]) / count turtles)) ] of turtles with  [color =  blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = blue  and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "square" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))] of turtles with [color = orange and shape = "circle" and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square" and color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle" and color = orange] / 8</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "square"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [color = [color] of myself]) / (count turtles-on neighbors)) / ((count turtles with [color = [color] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = blue  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [color = orange  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "square"   and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [(((count (turtles-on neighbors) with [shape = [shape] of myself]) / (count turtles-on neighbors)) / ((count turtles with [shape = [shape] of myself]) / count turtles))]  of turtles with [shape = "circle"  and count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = blue] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [color = orange] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "square"] / 8</metric>
    <metric>mean [ count (turtles-on neighbors) / (count turtles / count patches)] of turtles with [shape = "circle"] / 8</metric>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%majority">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_maj">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%liberal_min">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta_distribution">
      <value value="&quot;by-value&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_maj">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lib_min">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dominant">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="secondary">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="con_eth" first="0" step="1" last="20"/>
    <steppedValueSet variable="lib_val" first="0" step="1" last="20"/>
    <enumeratedValueSet variable="lib_eth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="con_val">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eth_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_con_min">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_maj">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="val_lib_min">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
