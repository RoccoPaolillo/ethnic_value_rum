extensions [rnd]


globals [
  percent-similar-eth
  percent-similar-val
]

patches-own [
 uti-eth
 uti-val
]

turtles-own [
  ethnicity
similar-ethnics
  total-neighbors
  ethnic-utility
  value-utility
  similar-value
  total-utility
  i_e
  i_v
]

to setup
 ; random-seed 100
  clear-all
  ask patches [set pcolor white
    if random 100 < density [sprout 1 [


     ifelse random 100 < fraction_blue
      [set ethnicity "local"
       set color blue
        set shape ifelse-value (random 100 < circle_blue) ["circle"]["square"]          ; attributes of agents
      ]

      [set ethnicity "minority"
       set color orange
        set shape ifelse-value (random 100 < circle_orange) ["circle"]["square"]
      ]
    ;  attribute_preferences
      ]
    ]
  ]
 update-turtles
 update-globals
 ; random-seed new-seed
  reset-ticks
end


to go
  update-turtles     ; updates of utility of turtles
  move-turtles       ; relocation decision of turtles
  update-globals     ; global reportes
tick
end




to move-turtles          ; choice for each turtle. The agent makes a patch-set combined of current location and an empty patch (the options)

  ask turtles [

    let beta-ie ifelse-value (ethnicity = "local") [ifelse-value (shape = "square") [e_blue_sqr][e_blue_crl]] [ifelse-value (shape = "square")[e_orng_sqr][e_orng_crl]]
    let beta-iv ifelse-value (ethnicity = "local") [ifelse-value (shape = "square") [v_blue_sqr][v_blue_crl]] [ifelse-value (shape = "square")[v_orng_sqr][v_orng_crl]]

   let ethnicity-myself ethnicity    ;  needed as local variable to be computed by the options of patch-set
   let shape-myself shape


    let options (patch-set patch-here n-of num_alternative patches with [not any? turtles-here])    ; the list of options is made: made up of current node plus alternative empty nodes.
                                                                                                    ; number of alternatives to current location can be set with num_alternative

    ask options [                       ; the ethnic and value utility are computed for each option of the agent. Utility is computed through the reporter below
                                        ; Options are local to the caller turtle

      let xe count (turtles-on neighbors) with [ethnicity = ethnicity-myself]
      let xv count (turtles-on neighbors) with [ shape = shape-myself]

      let n count (turtles-on neighbors)

      set uti-eth utility xe n similar_wanted_ethnic   ; value utility and ethnic utility of each option
      set uti-val utility xv n similar_wanted_value
    ]

   move-to rnd:weighted-one-of options [exp ((beta-ie * (uti-eth)) + (beta-iv * (uti-val)))]  ; roulette wheel: move to one option according to probability derived by expU,
                                                                                                   ; U of each dimension = beta_ethnic*ethnic_utility + beta_value*value_utility
                                                                                                   ; RND roulette-wheel: sorts the options to move to according to expU/Sum(expU)



  ]


end

to update-turtles                           ; updates of preferences of turtles

  ask turtles[

    set similar-ethnics (count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself])       ; these are just to have reporters to check in the simulation
    set similar-value (count (turtles-on neighbors) with [shape = [shape] of myself])
    set total-neighbors (count turtles-on neighbors)
    set ethnic-utility  utility similar-ethnics total-neighbors similar_wanted_ethnic
    set value-utility  utility  similar-value total-neighbors similar_wanted_value
    set total-utility (ethnic-utility + value-utility)

  ]
end

to update-globals

  let tot-ethnics sum [ similar-ethnics ] of turtles               ; reporters for emerging properties: ethnic  and value segregation
  let tot-value sum [ similar-value ] of turtles
 let tot-neighbors sum [ total-neighbors ] of turtles
  set percent-similar-val (tot-value / tot-neighbors) * 100
  set percent-similar-eth (tot-ethnics / tot-neighbors) * 100
end


to-report utility [a b c]  ; the three types of utility functions: threshold, single-peaked, linear + constant , a = number similar neighborhood, b = total number neighborhood, f = concentration preference

report ( ifelse-value (b = 0) [0]               ; empty neighborhoods (total number of neighbors 0) have 0, whatever the desired concentration is (previously they would have positevely assessed if desired concentration was 0)
    [ ifelse-value (a = (b * c)) [1]            ; to avoid problems when desired concentration is 0. Maximum utility is 1, i.e. concentration of similar ones is the same of desired concentration
      [ifelse-value (a < (b * c))
      [precision (a / (b * c)) 3                 ; for concentration of similars below the desired concentration
        ][ precision (c + (((1 - (a / b)) * (1 - c)) / (1 - c))) 3]     ; for concentration above the desired concentration.
      ]
    ]
    )

end    ; single-peaked function for desired concentration, same as INFO: https://docs.google.com/document/d/1ohT817vJSuf6gCnpiea6OB6wLsMYcJrOnC7nBRzLr9M/edit?usp=sharing
@#$#@#$#@
GRAPHICS-WINDOW
253
10
710
468
-1
-1
8.804
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
101
10
222
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
101
49
223
82
fraction_blue
fraction_blue
50
100
80.0
1
1
NIL
HORIZONTAL

BUTTON
578
479
641
512
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
645
479
708
512
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
722
318
979
462
segregation-global
NIL
NIL
0.0
10.0
0.0
101.0
true
true
"" ""
PENS
"eth-seg" 1.0 0 -5825686 true "" "plot percent-similar-eth"
"val-seg" 1.0 0 -10899396 true "" "plot percent-similar-val"

TEXTBOX
29
16
91
51
population parameters
11
0.0
1

SLIDER
25
91
117
124
circle_blue
circle_blue
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
119
92
223
125
circle_orange
circle_orange
0
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
274
482
336
527
circle_blue
count turtles with [shape = \"circle\" and ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
340
482
412
527
square_bue
count turtles with [shape = \"square\" and  ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
417
478
497
523
circle_orange
count turtles with [shape = \"circle\" and ethnicity = \"minority\"] / count turtles
2
1
11

MONITOR
415
526
499
571
square_orange
count turtles with [shape = \"square\" and ethnicity = \"minority\"] / count turtles
2
1
11

MONITOR
271
525
346
570
local/minority
count turtles with [ethnicity = \"local\"] / count turtles
2
1
11

MONITOR
351
527
411
572
circle_%
count turtles with [shape = \"circle\"] / count turtles
2
1
11

PLOT
722
163
977
313
circle-blue
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and ethnicity = \"local\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and ethnicity = \"local\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"circle\" and ethnicity = \"local\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [shape = \"circle\"  and ethnicity = \"local\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [shape = \"circle\"  and ethnicity = \"local\"]"

PLOT
721
10
980
160
square-blue
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and ethnicity = \"local\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [ shape = [ shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and ethnicity = \"local\"]"
"dennsity" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\" and ethnicity = \"local\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [shape = \"square\" and ethnicity = \"local\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [shape = \"square\" and ethnicity = \"local\"]"

PLOT
994
10
1224
160
square-orange
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
"eth" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and ethnicity = \"minority\"]"
"val" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"square\" and ethnicity = \"minority\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [shape = \"square\" and ethnicity = \"minority\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [shape = \"square\" and ethnicity = \"minority\"]"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [shape = \"square\" and ethnicity = \"minority\"]"

PLOT
996
164
1230
314
circle-orange
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
"ethnic" 1.0 0 -5825686 true "" "plot mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and shape = \"circle\" and ethnicity = \"minority\"]"
"value" 1.0 0 -10899396 true "" "plot mean [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and  shape = \"circle\"  and ethnicity = \"minority\"]"
"density" 1.0 0 -7500403 true "" "plot mean [count (turtles-on neighbors)] of turtles with [ shape = \"circle\"  and ethnicity = \"minority\"] / 8"
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles with [  shape = \"circle\"  and ethnicity = \"minority\"]"
"val-eth" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles with [ shape = \"circle\"  and ethnicity = \"minority\"]"

PLOT
996
316
1231
462
utility-global
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
"uti-eth" 1.0 0 -2674135 true "" "plot mean [ethnic-utility] of turtles"
"uti-val" 1.0 0 -13345367 true "" "plot mean [value-utility] of turtles"
"uti-tot" 1.0 0 -7500403 true "" "plot mean [total-utility] of turtles"

MONITOR
1228
10
1291
55
eth-sq-bl
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1226
60
1291
105
eth-sq-or
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1293
10
1353
55
val-sq-bl
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"  and ethnicity = \"local\"]
2
1
11

MONITOR
1294
59
1357
104
val-sq-or
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"s\"  and ethnicity = \"minority\"]
2
1
11

MONITOR
1228
110
1289
155
den_sq_bl
mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"local\"] / 8
2
1
11

MONITOR
1296
109
1358
154
den_sq_or
mean [count (turtles-on neighbors)] of turtles with [first shape = \"s\" and ethnicity = \"minority\"] / 8
2
1
11

MONITOR
1359
10
1422
55
ut-et-sq-bl
mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1360
60
1426
105
ut-et-sq-or
mean [ethnic-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1427
10
1493
55
ut-vl-sq-bl
mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"local\"]
2
1
11

MONITOR
1430
58
1492
103
ut-vl-sq-or
mean [value-utility] of turtles with [first shape = \"s\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1233
164
1291
209
eth-cl-bl
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1294
164
1351
209
val-cl-bl
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"  and ethnicity = \"local\"]
2
1
11

MONITOR
1357
164
1424
209
ut-et-cl-bl
mean [ethnic-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1428
164
1493
209
ut-vl-cl-bl
mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"local\"]
2
1
11

MONITOR
1234
214
1291
259
eth-cl-or
mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1294
213
1352
258
val-cl-or
mean [count (turtles-on neighbors) with [first shape = [first shape] of myself] / count (turtles-on neighbors) ] of turtles with [ count (turtles-on neighbors) >= 1 and first shape = \"c\"  and ethnicity = \"minority\"]
2
1
11

MONITOR
1357
211
1425
256
ut-et-cl-or
mean [ethnic-utility] of turtles with [first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1428
212
1495
257
ut-vl-cl-or
mean [value-utility] of turtles with [first shape = \"c\" and ethnicity = \"minority\"]
2
1
11

MONITOR
1235
262
1291
307
den_cl_bl
mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"local\"] / 8
2
1
11

MONITOR
1295
260
1353
305
den_cl_or
mean [count (turtles-on neighbors)] of turtles with [first shape = \"c\" and ethnicity = \"minority\"] / 8
2
1
11

MONITOR
1239
315
1296
360
eth-seg
percent-similar-eth
2
1
11

MONITOR
1240
365
1297
410
val-seg
percent-similar-val
2
1
11

MONITOR
1302
314
1359
359
eth-uti
mean [ethnic-utility] of turtles
2
1
11

MONITOR
1302
364
1359
409
val-uti
mean [value-utility] of turtles
2
1
11

SLIDER
60
538
195
571
num_alternative
num_alternative
1
count patches with [not any? turtles-here]
1.0
1
1
NIL
HORIZONTAL

SLIDER
49
262
141
295
e_blue_sqr
e_blue_sqr
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
48
454
140
487
v_blue_crl
v_blue_crl
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
48
304
140
337
e_blue_crl
e_blue_crl
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
49
414
141
447
v_blue_sqr
v_blue_sqr
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
146
262
242
295
e_orng_sqr
e_orng_sqr
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
146
306
241
339
e_orng_crl
e_orng_crl
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
96
147
242
180
similar_wanted_ethnic
similar_wanted_ethnic
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
147
455
242
488
v_orng_crl
v_orng_crl
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
148
415
242
448
v_orng_sqr
v_orng_sqr
0
10
4.0
1
1
NIL
HORIZONTAL

TEXTBOX
84
239
231
257
distribution beta_ethnic
11
0.0
1

TEXTBOX
80
390
219
408
distribution beta_value
11
0.0
1

TEXTBOX
36
258
51
342
↓\n↓\n↓\n↓\n↓\n↓
11
0.0
1

TEXTBOX
5
279
37
314
value group
11
0.0
1

TEXTBOX
48
347
179
379
→→→→→→→→→→→\n         ethnic group
11
0.0
1

TEXTBOX
37
408
52
492
↓\n↓\n↓\n↓\n↓\n↓
11
0.0
1

TEXTBOX
5
436
39
468
value group
11
0.0
1

TEXTBOX
50
494
177
524
→→→→→→→→→→→\n         ethnic group
11
0.0
1

SLIDER
97
183
241
216
similar_wanted_value
similar_wanted_value
0
1
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
191
349
242
381
all four: all population
10
0.0
1

TEXTBOX
188
492
244
518
all four: all population
10
0.0
1

TEXTBOX
13
164
81
202
desired concentration
11
0.0
1

MONITOR
571
543
652
588
prop_minority
count turtles with [ethnicity = \"minority\"] / count turtles
2
1
11

MONITOR
675
545
745
590
prop_local
count turtles with [ethnicity = \"local\"] / count turtles
2
1
11

@#$#@#$#@
## WHAT IS IT?

In the ACS paper we included an additional definition of agents as value for tolerance and included ethnic preferences and value preferences for agents according to their orientation. Here we extend the previous work connecting it to random utility models and paradigm of discrete choices. Both value utility and ethnic utility contribute to the desirability of the neighborhood and relocation choice of the agent. The former depends on the concentration of agents with the same values (shape), the latter depends on the concentration of agents with the same ethnicity (color).


## HOW IT WORKS

Agents represents households relocating in a city and are divided along two dimensions:
- ethnicity: color blue vs orange, independent of value orientation
- value orientation: square vs circle, independent of ethnicity

In a very simplified way, this represent how people can share different values and belong to different categories potentially independent of ethnic membership and that serve to define boundaries and membership between groups (Wimmer, 2009). In this study, this is applied to definition of homophily preferences within residential choice.

Homophily preferences:
- Ethnic preference: desired concentration of turtles of same ethnicity (color) in neighborhood
- Value preference: desired concentration of turtles of same value (shape) in neighborhood

Fitting random utility, each agent compares the current location to a number of alternative locations. They hold preference for desired concentration U, which determines how a neighborhood is desirable for that dimension, depending on parameters betas. The systematic component of utility of a neighborhood is:

U = (beta_ethnic * ethnic_utility) + (beta_value * value_utility)

The probability of choosing one option over the others, include the random-term along the systematic utility as in random utility models. The influence of random term or the systematic utility over the probability of choice depends on the beta parameter. The higher beta for one dimension, the more the best option for that dimension will be chosen; the lower the beta, the more random one option is chosen for one dimension (each one has .50 probability to be chosen). Beta equal 0 means the choice is totally random. Even for highest levels of betas, still a component of randomness is included. The probability for each option m to be chosen over all options k is:

Pm = exp(Um) /Sum(expUk)

In this simulation, probability to relocate is implemented with the roulette wheel selection through RND extension:

move-to rnd:weighted-one-of options [exp ((beta-ie * (uti-eth)) + (beta-iv * (uti-val)))]

where options is the list = choice set each agent builds at local level and exp((beta_e*U_e) + (beta-iv *U_v)) (the systematic component of utility) is the size according to which one option has weighted probability to be selected.

Beta parameters can be uniformly distributed across the entire population, ethnic group, value orientation, or specific subgroup of the interaction ethnicity X value orientation

## HOW TO USE IT

Population parameters:
- density of society
- fraction_blue: relative group sizes local population / minority population
- circle_blue, circle_orange: ratio of value oriented within each group

Desired concentration:
The only slope for utility function here is the single-peaked function: parameter equal to 1 represent the linear function. This is uniform for all turtles, not matter their ethnicity or value orientation.
- similar_wanted_ethnic: ethnic composition
- similar_wanted_value: value composition
Here the slope for diverse desired concentration:
https://docs.google.com/document/d/1ohT817vJSuf6gCnpiea6OB6wLsMYcJrOnC7nBRzLr9M/edit?usp=sharing

Distribution_beta_ethnic and Distribution_beta_value:
Beta parameters. They are independent for the ethnic dimension and value dimension of utility. Uniformly distributed at local level of turtles depending on their ethnicity (color) and value orientation (shape). The interface shows how to combine their uniform distribution:
- according to ethnicity on x-axis
- according to value on the y-axis
- all population: all four betas for that dimension equal

Number of alternative
- num_alternative: the number of locations alternative to the current node. Current node is always part of the choice set (in the code patch-set options). Parameter goes from 1 (binary choice logit) to all available empty patches (multinomial choice logit), tunable.


## THINGS TO NOTICE

- Ethnic segregation
- Value segregation
- Density neighborhood
- Increment of utility. Utility is both for ethnic and value composition and the sum of them.


## CREDITS AND REFERENCES

Schelling, T. C. (1969). Models of segregation. The American Economic Review, 59(2), 488-493
Paolillo, R., & Lorenz, J. (2018). How different homophily preferences mitigate and spur ethnic and value segregation: Schelling’s model extended. Advances in Complex Systems, 21(06n07), 1850026.
Bruch, E. E., & Mare, R. D. (2006). Neighborhood choice and neighborhood change. American Journal of sociology, 112(3), 667-709.
Zhang, J. (2004). Residential segregation in an all-integrationist world. Journal of Economic Behavior & Organization, 54(4), 533-550.
Wimmer, A. (2008). The making and unmaking of ethnic boundaries: A multilevel process theory. American journal of sociology, 113(4), 970-1022.
Train, K. E. (2009). Discrete choice methods with simulation. Cambridge university press.
Hess, S., Daly, A., & Batley, R. (2018). Revisiting consistency with random utility maximisation: theory and implications for practical work. Theory and Decision, 84(2), 181-204.
McFadden, Daniel. 1994. Conditional Logit Analysis of Qualitative Choice Behavior. Edited by P. Zarembka. New York, NY:Academic Press.
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
  <experiment name="experiment" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [total-utility] of turtles</metric>
    <metric>mean [ethnic-utility] of turtles</metric>
    <metric>mean [value-utility] of turtles</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority"]</metric>
    <metric>mean [total-utility] of turtles  with [shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "square"]</metric>
    <metric>mean [total-utility] of turtles  with [shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local" and shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority" and shape = "circle"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "circle"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "local" and shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "local" and shape = "square"]</metric>
    <metric>mean [total-utility] of turtles  with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [ethnic-utility] of turtles with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [value-utility] of turtles with [ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean [count (turtles-on neighbors)]  of turtles  with [ethnicity = "minority" and shape = "square"] / 8</metric>
    <metric>mean [count (turtles-on neighbors) with [ethnicity = [ethnicity] of myself] / count (turtles-on neighbors)] of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "square"]</metric>
    <metric>mean  [count (turtles-on neighbors) with [shape = [shape] of myself] / count (turtles-on neighbors)]  of turtles with [count (turtles-on neighbors) &gt;= 1 and ethnicity = "minority" and shape = "square"]</metric>
    <enumeratedValueSet variable="i_v_cl">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_e_cl">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_e_sq">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utility_function">
      <value value="&quot;threshold&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i_v_sq">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fraction_blue">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="circle_orange">
      <value value="50"/>
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
