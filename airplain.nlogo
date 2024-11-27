__includes ["communication.nls" "bdi.nls"]

globals [
  checkin-boxes
  passport-controls
  info-screen
  shops
  boarding-gates
  belts
  baggage-screen
  output
  total-satisfaction
  total-satisfactionAmI
  average-time
  average-timeAmI
  show-intentions
  show_messages
]

to setup
  clear-all
  reset-ticks
  set show-intentions true
  set show_messages true
  set total-satisfaction 0
  set total-satisfactionAmI 0
  set average-time 0
  set average-timeAmI 0
  set checkin-boxes []

  ask patches [ set pcolor white ]

  ;; Генерація зон аеропорту
  set checkin-boxes generate-elist num-checkin-boxes (2 * max-pycor / 3) max-pycor
  foreach checkin-boxes [ ask ? [ set pcolor red ] ]

  set info-screen patch (max-pxcor / 2) (5 * max-pycor / 6)
  ask info-screen [ set pcolor cyan ]

  let wall patches with [pycor = 2 * max-pycor / 3]
  ask wall [ set pcolor black ]

  set passport-controls generate-clist num-passport-controls (2 * max-pycor / 3)
  foreach passport-controls [ ask ? [ set pcolor yellow ] ]

  set shops generate-elist num-shops (max-pycor / 3) (2 * max-pycor / 3)
  foreach shops [ ask ? [ set pcolor green ] ]

  set boarding-gates generate-clist num-gates 0
  foreach boarding-gates [ ask ? [ set pcolor pink ] ]

  set belts generate-elist num-belts 0 (max-pycor / 3)
  foreach belts [ ask ? [ set pcolor gray ] ]

  set baggage-screen patch (max-pxcor / 2) (max-pycor / 6)
  ask baggage-screen [ set pcolor brown ]

  set output patch (max-pxcor / 2) max-pycor

  ;; Створення агентів
  create-baggage 1 [ setup-baggage ]
  create-belt num-belts [ setup-belt ]
  create-control num-passport-controls [ setup-control ]
  create-shop num-shops [ setup-shop ]
  create-gate num-gates [ setup-gate ]
  create-infocheckin 1 [ setup-infocheckin ]
  create-check num-checkin-boxes [ setup-check ]
  create-outgoing num-outgoing [ setup-outgoing ]
  create-ingoing num-ingoing [ setup-ingoing ]
  create-outgoingAmI numoutgoingAmI [ setup-outgoingAmI ]
  create-ingoingAmI numingoingAmI [ setup-ingoingAmI ]

  ;; Відображення моделі (опціонально)
  ; movie-start "out.mov"
  ; movie-grab-view
end
breed [baggage a-baggage]
baggage-own [incoming-queue]

to setup-baggage
  set incoming-queue []  ;; Ініціалізуємо чергу як порожній список
end

to baggage-execution
  if not empty? incoming-queue [  ;; Якщо черга не порожня
    let in_msg first incoming-queue  ;; Отримуємо перше повідомлення з черги
    let sender "Unknown"  ;; Місце для збереження відправника, можна змінити за потребою
    let mybelt item random num-belts belts  ;; Випадковий вибір поясу
    let reply_msg word "inform" " " in_msg  ;; Створюємо повідомлення (у цей момент поки що спрощуємо)
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Belt " mybelt " ; AID: " sender " ; Service (Name: Baggage-Delivery) )")  ;; Формуємо вміст
    ;; Додаємо вміст до повідомлення і відправляємо (приклад простої логіки для перевірки)
    print content  ;; Для перевірки, що відправляється повідомлення
    set incoming-queue but-first incoming-queue  ;; Видаляємо перше повідомлення з черги
  ]
end



breed [belt a-belt]
belt-own [incoming-queue]

to setup-belt
  set incoming-queue []
end

to belt-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "done" in_msg
    let baggage-size random 2
    let content (word "Provide (Product (Name: Baggage-Delivery ; Characteristics: Baggage-Number " baggage-size " ) ; AID: " sender " )")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end

breed [control a-control]
control-own [incoming-queue]

to setup-control
  set incoming-queue []
end

to control-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "done" in_msg
    let danger random-exponential 1
    let content (word "Provide (Product (Name: Passport-Control ; Characteristics: Danger " danger " ) ; AID: " sender " )")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end

breed [shop a-shop]
shop-own [incoming-queue]

to setup-shop
  set incoming-queue []
end

to shop-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "done" in_msg
    let interest random 10
    let content (word "Provide (Product (Name: Shopping ; Characteristics: Interest " interest " ) ; AID: " sender " )")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end
breed [gate a-gate]
gate-own [incoming-queue]

to setup-gate
  set incoming-queue []
end

to gate-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "inform" in_msg
    let mygate item random num-gates boarding-gates
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Gate " mygate " ; AID: " sender " ; Service (Name: Boarding))")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end

breed [infocheckin a-infocheckin]
infocheckin-own [incoming-queue]

to setup-infocheckin
  set incoming-queue []
end

to infocheckin-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "inform" in_msg
    let mycheckin item random num-checkin-boxes checkin-boxes
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Checkin-Box " mycheckin " ; AID: " sender " ; Service (Name: Checkin))")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end

breed [check a-check]
check-own [incoming-queue]

to setup-check
  set incoming-queue []
end

to check-execution
  if not empty? incoming-queue [
    let in_msg get-message
    let sender get-sender in_msg
    let reply_msg create-reply "done" in_msg
    let baggage-size random 2
    let content (word "Provide (Product (Name: Checkin ; Characteristics: Baggage-Number " baggage-size " ) ; AID: " sender " )")
    set reply_msg add-content content reply_msg
    send reply_msg
  ]
end

breed [ingoingAmI a-ingoingAmI]
ingoingAmI-own [beliefs intentions incoming-queue]

to setup-ingoingAmI
  set shape "person"
  set color green
  set beliefs []
  set intentions []
  set incoming-queue []

  ;; Ініціалізація вірувань (beliefs)
  add-belief create-belief "time-left" 0
  add-belief create-belief "time-control" 0
  add-belief create-belief "time-shopping" 0
  add-belief create-belief "danger" random-exponential 1
  add-belief create-belief "num-baggage" random 2
  add-belief create-belief "time-belts" 0

  ;; Розташування агента біля воріт (gate)
  let my-gate item random num-gates boarding-gates
  move-to my-gate

  ;; Інтереси для шопінгу
  let i num-shops
  let si []
  while [i > 0] [
    set si fput (random 10) si
    set i i - 1
  ]
  add-belief create-belief "shopping-interests" si

  ;; Ініціалізація намірів (intentions)
  add-intention "move-to-output" "in-output"
  add-intention "pass-control" "past-control"
  add-intention "move-to-control" "in-control"
  add-intention "shopping" "shopped"
  add-intention "move-to-interestingshop" "in-interestingshop"
  add-intention "collect-baggage" "baggage-collected"
  add-intention "move-to-belt" "in-belt"
  add-intention "ask-baggage-info" "informed-belt-baggage"
end
to move-to-interestingshop
  let d distance (belief-content read-first-belief-of-type "most-interesting-shop")
  let as turtles-on (belief-content read-first-belief-of-type "most-interesting-shop")

  ifelse (d > 1 or not any? as) [
    face (belief-content read-first-belief-of-type "most-interesting-shop")
    fd 1
  ] [
    set total-satisfaction total-satisfaction - 1
  ]
end

to-report in-interestingshop
  let most-interesting-shop belief-content read-first-belief-of-type "most-interesting-shop"
  let time-to-shop belief-content read-first-belief-of-type "time-to-shop"
  let time-shopping belief-content read-first-belief-of-type "time-shopping"

  if patch-here = most-interesting-shop [
    ifelse time-shopping <= time-to-shop [
      update-belief create-belief "time-shopping" (time-shopping + 1)
      report false
    ] [
      let interest belief-content read-first-belief-of-type "shopping-interest"
      set total-satisfaction interest + total-satisfaction
      report true
    ]
  ] [
    report false
  ]
end

to move-to-shops
  let current-shop item (belief-content read-first-belief-of-type "current-shop") shops
  let d distance current-shop
  let as turtles-on current-shop

  ifelse (d > 1 or not any? as) [
    face current-shop
    fd 1
  ] [
    set total-satisfaction total-satisfaction - 1
  ]
end

to-report in-shops
  let current-shop item (belief-content read-first-belief-of-type "current-shop") shops

  if patch-here = current-shop [
    let most-interesting-shop belief-content read-first-belief-of-type "most-interesting-shop"
    ifelse patch-here = most-interesting-shop [
      let time-to-shop belief-content read-first-belief-of-type "time-to-shop"
      let time-shopping belief-content read-first-belief-of-type "time-shopping"

      ifelse time-shopping <= time-to-shop [
        update-belief create-belief "time-shopping" (time-shopping + 1)
        report false
      ] [
        let interest belief-content read-first-belief-of-type "shopping-interest"
        set total-satisfaction interest + total-satisfaction
        report true
      ]
    ] [
      let current-shop-number belief-content read-first-belief-of-type "current-shop"
      update-belief create-belief "current-shop" (current-shop-number - 1)
      report false
    ]
  ] [
    report false
  ]
end
to shopping
  if (not exist-beliefs-of-type "shopping-requested") [
    let out_msg create-message "request"
    let receiver one-of shop
    let sender get-sender out_msg
    set out_msg add-receiver ([who] of receiver) out_msg
    let interest random 10
    let content (word "Provide (Product (Name: Shopping ; Characteristics: Interest " interest " ) ; AID: " sender " )")
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "shopping-requested" true
  ]
end

to-report shopped
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let requested get-belief "shopping-requested"
    report true
  ] [
    report false
  ]
end

to pass-control
  if (not exist-beliefs-of-type "control-requested") [
    let out_msg create-message "request"
    let receiver one-of control
    let sender get-sender out_msg
    set out_msg add-receiver ([who] of receiver) out_msg
    let danger random-exponential 1
    let content (word "Provide (Product (Name: Passport-Control ; Characteristics: Danger " danger " ) ; AID: " sender " )")
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "control-requested" true
  ]
end

to-report past-control
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let requested get-belief "control-requested"
    report true
  ] [
    report false
  ]
end

to ask-baggage-info
  if (not exist-beliefs-of-type "belt-requested") [
    let out_msg create-message "query"
    let receiver one-of baggage
    let sender get-sender out_msg
    set out_msg add-receiver ([who] of receiver) out_msg
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Belt ; AID: " sender " ; Service (Name: Baggage-Delivery)")
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "belt-requested" true
  ]
end

to-report informed-belt-baggage
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let mybelt item random num-belts belts
    add-belief create-belief "mybelt" mybelt
    let requested get-belief "belt-requested"
    report true
  ] [
    report false
  ]
end

to collect-baggage
  if (not exist-beliefs-of-type "baggage-requested") [
    let out_msg create-message "request"
    let receiver one-of belt
    let sender get-sender out_msg
    set out_msg add-receiver ([who] of receiver) out_msg
    let baggage-size random 2
    let content (word "Provide (Product (Name: Baggage-Delivery ; Characteristics: Baggage-Number " baggage-size " ) ; AID: " sender " )")
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "baggage-requested" true
  ]
end

to-report baggage-collected
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let requested get-belief "baggage-requested"
    report true
  ] [
    report false
  ]
end

to move-to-baggage-info
  face baggage-screen
  fd 1
end

to-report in-baggage-info
  ifelse (patch-here = baggage-screen) [
    report true
  ] [
    report false
  ]
end

to-report in-belt
  ifelse (patch-here = belief-content read-first-belief-of-type "mybelt") [
    let num-baggage belief-content read-first-belief-of-type "num-baggage"
    let time-belts belief-content read-first-belief-of-type "time-belts"
    ifelse (time-belts <= num-baggage) [
      update-belief create-belief "time-belts" (time-belts + 1)
      report false
    ] [
      let i random num-shops
      let most-interesting-shop item i shops
      add-belief create-belief "most-interesting-shop" most-interesting-shop
      let time-to-shop random-normal 3 2
      add-belief create-belief "time-to-shop" time-to-shop
      let interest item i belief-content read-first-belief-of-type "shopping-interests"
      add-belief create-belief "shopping-interest" interest
      let mycontrol item random num-passport-controls passport-controls
      add-belief create-belief "mycontrol" mycontrol
      report true
    ]
  ] [
    report false
  ]
end

to move-to-belt
  let d distance belief-content read-first-belief-of-type "mybelt"
  let as turtles-on belief-content read-first-belief-of-type "mybelt"
  ifelse ((d > 1) or (not any? as)) [
    face belief-content read-first-belief-of-type "mybelt"
    fd 1
  ] [
    set total-satisfaction total-satisfaction - 1
  ]
end

to move-to-control
  let mycontrol belief-content read-first-belief-of-type "mycontrol"
  let d distance mycontrol
  let as turtles-on mycontrol
  ifelse ((d > 1) or (not any? as)) [
    face mycontrol
    fd 1
  ] [
    set total-satisfaction total-satisfaction - 1
  ]
end

to-report in-control
  let mycontrol belief-content read-first-belief-of-type "mycontrol"
  ifelse (patch-here = mycontrol) [
    let time-control belief-content read-first-belief-of-type "time-control"
    let danger belief-content read-first-belief-of-type "danger"
    ifelse (time-control <= danger) [
      update-belief create-belief "time-control" (time-control + 1)
      report false
    ] [
      report true
    ]
  ] [
    report false
  ]
end
breed [outgoing]
outgoing-own [beliefs intentions incoming-queue]

;; time-left time-control danger

to setup-outgoing
  set beliefs []
  set intentions []
  set incoming-queue []
  set xcor ( max-pxcor / 2 )
  set ycor max-pycor
  set color blue
  set shape "person"
  add-belief create-belief "time-left" 0
  add-belief create-belief "time-control" 0
  add-belief create-belief "time-shopping" 0
  add-belief create-belief "danger" random-exponential 1
  add-belief create-belief "num-baggage" random 2
  add-belief create-belief "time-boarding" 0
  add-belief create-belief "time-checkin" 0

  let i num-shops
  let si []
  while [ i > 0 ] [
    set si fput (random 10) si
    set i i - 1
  ]
  add-belief create-belief "shopping-interests" si
  add-intention "move-to-gate" "in-gate"
  add-intention "query-gate" "informed-gate"
  add-intention "move-to-gate-info" "in-gate-info"
  add-intention "shopping" "shopped"
  add-intention "move-to-interestingshop" "in-interestingshop"
  add-intention "pass-control" "past-control"
  add-intention "move-to-control" "in-control"
  add-intention "request-checkin" "done-checkin"
  add-intention "move-to-checkin" "in-checkin"
  add-intention "query-checkin" "informed-checkin"
  add-intention "move-to-checkin-info" "in-checkin-info"
end

to move-to-checkin
  let d distance
  let as turtles-on
  ifelse ( ( d > 1 ) or ( not any? as ) )
  [
    face
    fd 1
  ]
  [
    set total-satisfaction total-satisfaction - 1
  ]
end

to-report in-checkin
  ifelse ( patch-here = belief-content read-first-belief-of-type "mycheckin" )
  [
    let num-baggage belief-content read-first-belief-of-type "num-baggage"
    let time-checkin belief-content read-first-belief-of-type "time-checkin"
    ifelse ( time-checkin <= num-baggage )
    [
      update-belief create-belief "time-checkin" (time-checkin + 1)
      report false
    ]
    [
      report true
    ]
  ]
  [
    report false
  ]
end

to outgoing-execution
  execute-intentions
end

to move-to-checkin-info
  face info-screen
  fd 1
end

to move-to-gate-info
  face baggage-screen
  fd 1
end

to-report in-gate-info
  ifelse ( patch-here = baggage-screen )
  [
    report true
  ]
  [
    report false
  ]
end

to-report in-checkin-info
  ifelse ( patch-here = info-screen )
  [
    report true
  ]
  [
    report false
  ]
end

to query-gate
  if (not exist-beliefs-of-type "gate-requested")
  [
    let out_msg create-message "query"
    let receiver one-of baggage
    let sender get-sender out_msg
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Gate ; AID: " sender " ; Service (Name: Boarding)")
    set out_msg add-receiver ([who] of receiver) out_msg
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "gate-requested" true
  ]
end

to request-checkin
  if (not exist-beliefs-of-type "checkin-requested")
  [
    let out_msg create-message "request"
    let receiver one-of check
    let sender get-sender out_msg
    set out_msg add-receiver ([who] of receiver) out_msg
    let baggage-size random 2
    let content (word "Provide (Product (Name: Checkin ; Characteristics: Baggage-Number " baggage-size " ) ; AID: " sender " )")
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "checkin-requested" true
  ]
end

to-report done-checkin
  ifelse (not empty? incoming-queue)
  [
    let in_msg get-message
    let content (get-content in_msg)
    let requested get-belief "checkin-requested"
    let mycontrol item random num-passport-controls passport-controls
    add-belief create-belief "mycontrol" mycontrol
    report true
  ]
  [
    report false
  ]
end

to query-checkin
  if (not exist-beliefs-of-type "checkin-queried")
  [
    let out_msg create-message "query"
    let receiver one-of infocheckin
    let sender get-sender out_msg
    let content (word "isProvider (Place (Building Airport ; Floor 0) ; Position: Checkin-Box ; AID: " sender " ; Service (Name: Checkin)")
    set out_msg add-receiver ([who] of receiver) out_msg
    set out_msg add-content content out_msg
    send out_msg
    add-belief create-belief "checkin-queried" true
  ]
end
to-report informed-checkin
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let mycheckin item random num-checkin-boxes checkin-boxes
    add-belief create-belief "mycheckin" mycheckin
    let requested get-belief "checkin-queried"
    let j random num-shops
    let most-interesting-shop item j shops
    add-belief create-belief "most-interesting-shop" most-interesting-shop
    let time-to-shop random-normal 3 2
    add-belief create-belief "time-to-shop" time-to-shop
    let interest item j belief-content read-first-belief-of-type "shopping-interests"
    add-belief create-belief "shopping-interest" interest
    report true
  ]
  [
    report false
  ]
end

to-report informed-gate
  ifelse (not empty? incoming-queue) [
    let in_msg get-message
    let content (get-content in_msg)
    let mygate item random num-gates boarding-gates
    add-belief create-belief "mygate" mygate
    let requested get-belief "gate-requested"
    report true
  ]
  [
    report false
  ]
end

to move-to-gate
  let mygate belief-content read-first-belief-of-type "mygate"
  face mygate
  fd 1
end

to-report in-gate
  let mygate belief-content read-first-belief-of-type "mygate"
  ifelse (patch-here = mygate) [
    hide-turtle
    set average-time average-time + ticks
    report true
  ]
  [
    report false
  ]
end

to-report generate-elist [ num miny maxy ]
  ;; left
  let inc ((maxy - miny) / (num / 2 - num mod 2 + 1))
  let i (inc + miny)
  let p []
  let l sort p
  while [ i < maxy ] [
    set p (patch-set patch 0 i p)
    set l sort p
    set i (inc + i)
  ]
  ;; right
  set inc ((maxy - miny) / (num - num / 2 + 1))
  set i (inc + miny)
  while [ i < maxy ] [
    set p (patch-set patch max-pxcor i p)
    set l sort p
    set i (inc + i)
  ]
  report l
end

to-report generate-clist [ num y ]
  let inc (max-pxcor / (num + 1))
  let i inc
  let p []
  let l sort p
  while [ inc < max-pxcor ] [
    set p (patch-set patch inc y p)
    set l sort p
    set inc (inc + i)
  ]
  report l
end

to go
  ;; go-outgoing
  ask baggage [baggage-execution]
  ask belt [belt-execution]
  ask control [control-execution]
  ask shop [shop-execution]
  ask gate [gate-execution]
  ask infocheckin [infocheckin-execution]
  ask check [check-execution]
  ask ingoing [ingoing-execution]
  ask outgoing [outgoing-execution]
  ask ingoingAmI [ingoingAmI-execution]
  ask outgoingAmI [outgoingAmI-execution]
  tick
  do-plots
  if (ticks > 360) [ stop ] ;; movie-close перед stop
end

to do-plots
  set-current-plot "plot1"
  set-current-plot-pen "satisfaction"
  plotxy ticks (total-satisfaction / (num-ingoing + num-outgoing))
  set-current-plot-pen "satisfactionAmI"
  plotxy ticks (total-satisfactionAmI / (numingoingAmI + numoutgoingAmI))
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
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
