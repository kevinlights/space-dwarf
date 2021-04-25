;; click, active, export-table :timer

(local mater {:asteroid 6
              :transport 30
              :pirate 20
              :drone 20
              :diplomat 30
              :corvette 40
              :cruiser 10})

(local hardpoints {:asteroid []
                   :transport [:point-defense]
                   :pirate [:missile-launcher :ceramic-armour]
                   :drone [:laser :sheild]
                   :diplomat [:ceramic-armour :sheild :missile-launcher]
                   :corvette [:missile-launcher :sheild :laser :point-defense]
                   :cruiser [:missile-launcher :sheild :laser :ceramic-armour :point-defense]})

(local aux {:asteroid []
            :transport [:mass-ordinance]
            :pirate [:mass-ordinance :missiles]
            :drone [:capacitor :capacitor]
            :diplomat [:missile :missile :missile :capacitor]
            :corvette [:mass-ordinance :capacitor :capacitor :missile :missile]
            :cruiser [:mass-ordinance :capacitor :missile :missile]
            })

(local notes (. (require :state) :objects :console :notes))

(local ship-setups (. (require :state) :objects :enemy-ship :ship-setups))

(local encounters {:asteroid-1 [:asteroid 0 :Asteroids]
                   :asteroid-2 [:asteroid 0 :Asteroids]
                   :transport [:transport 1 :Transport]
                   ;; :pirate-1 [:pirate 1 :Sloop]
                   :pirate-2 [:pirate 2 :Sloop]
                   ;; :drone-1 [:drone 1 :Drone]
                   :drone-2 [:drone 2 :Drone]
                   :diplomat-1 [:diplomat 2 :Diplomat]
                   :diplomat-2 [:diplomat 3 :Diplomat]
                   ;; :corvette-1 [:corvette 3 :Corvette]
                   :corvette-2 [:corvette 4 :Corvette]
                   ;; :cruiser-1 [:cruiser 4 :Cruiser]
                   :cruiser-2 [:cruiser 5 :Cruiser]
                   })

(fn setup-encounter [name encounter ship-setups style notes hardpoint-count hardpoints aux mater]
  (let [loadout (lume.slice hardpoints hardpoint-count)
        enemy-table (lume.concat loadout aux)]
    ;; instantiate notes for encounter
    (each [state value (pairs (encounter.notes loadout aux mater style))]
      (notes (.. state "-" name) value))
    ;; instatantiate ship setup for encounter
    (tset ship-setups name {:name style :has enemy-table})
    ;; instatantiate node for encounter
    (let [ret {:state (or encounter.state :warp)
               ;; Default States
               :states {:warp {:note (.. :warp- name) :requirements {:timer 15}}
                        :notification {:note (.. :notification- name) :requirements {:click :got-it}}
                        :battle {:note (.. :battle- name) :requirements {:timer 2}}
                        :failure {:note (.. :failure- name) :mater 10 :requirements {:timer 15}}
                        :success {:note (.. :success- name) :mater mater :requirements {:timer 15}}
                        }
               }
          states (or encounter.states {})]
      ;; Overwrite default states
      (each [state value (pairs states)]
        (each [element v (pairs value)]
          (when (not (. ret.states state))
            (tset ret.states state {}))
          (tset (. ret.states state) element v)))
      ret)))


;; {:asteroid-1 {:states {:warp {:note :warp-asteroid-1 :requirements {:click :got-it }}
;;                        :notification {:note :notification-asteroid-1 :requirements {:active [:ceramic-armour]}}
;;                        :ready {:note :ready-asteroid-1 :requirements {:click :got-it}}
;;                        :battle {}
;;                        :failure {:note :failure-asteroid-1 :mater mater.asteroid :requirements {:click :got-it}}
;;                        :success {:note :success-asteroid-1 :mater mater.asteroid :requirements {:click :got-it}}
;;                        }
;;               :state :warp}
;;  :asteroid-2 {:states {:warp {:note :warp-asteroid-2 :requirements {:timer 15}}
;;                        :notification {:note :notification-asteroid-2 :requirements {:active [:ceramic-armour]}}
;;                        :ready {:note :ready-asteroid-1 :requirements {:click :got-it}}
;;                        :battle {}
;;                        :failure {:note :failure-asteroid-1 :mater mater.asteroid :requirements {:click :got-it}}
;;                        :success {:note :success-asteroid-1 :mater mater.asteroid :requirements {:click :got-it}}
;;                        }
;;               :state :warp}
;;   :transport {:states {:warp {:note :warp-transport :requirements {:timer 15}}
;;                        :notification {:note :notification-transport :requirements {:active [:point-defense] :export [:mass-ordinance]}}
;;                        :ready {:note :ready-transport :requirements {:click :got-it}}
;;                        :battle {}
;;                        :failure {:note :failure-transport :mater mater.transport :requirements {:click :got-it}}
;;                        :success {:note :success-transport :mater mater.transport :requirements {:click :got-it}}
;;                        }
;;               :state :warp}}


(let [ret {}]
         (each [name [type hardpoint-count style] (pairs encounters)]
           (tset ret name
                 (setup-encounter
                  name (require (.. :encounter- name)) ship-setups style notes hardpoint-count (. hardpoints type) (. aux type) (. mater type)))
           )
         ret)
