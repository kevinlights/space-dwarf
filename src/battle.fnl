(local state (require :state))

(local wear {})

(local support-wear {:missile-launcher 5
                     :laser 2
                     :point-defense 1
                     :shield 2})

(local translate {:point-defense "Railgun"
                  :ceramic-armour "Ceramic Armour"
                  :laser "Laser"
                  :shield "Shield"
                  :capacitor "Capacitor"
                  :missile "Missile"
                  :missile-launcher "Missile Launcher"
                  :mass-ordinance "Mass Ordinance"
                  })

(local text {:player {:missile-launcher "We Fired A Missile"
                      :laser "We Fired the Laser"
                      :point-defense "We Fired the Railgun"
                      :none "You have no weapons!"
                      :none-resolve "Nothing Happened..."
                      :down "Your Ship is Down!"}
             :enemy {:missile-lanuncher "Missile Incoming"
                     :laser "Beam Incoming"
                     :point-defense "Mass Ordinance Incoming"
                     :none "They have no weapons!"
                     :none-resolve "Nothing Happened..."
                     :down "There Ship is Down!"}
             })

(fn db [text])

(fn lg [battle text]
  (table.insert battle.state.log text))

(fn choose [hardpoints name]
  (db ["choose" name])
  (var ret nil)
  (each [_ hardpoint (ipairs hardpoints)]
    (when (and hardpoint (= name (hardpoint:get-name)))
      (set ret hardpoint)))
  ret
  )

(fn has [hardpoints name]
  (db ["has" name])
  (if (choose hardpoints name)
      true
      false)
  )

(fn none? [hardpoints]
  (= 0 (# hardpoints)))

(fn intercept [battle chance always-call call-on-fail]
  (always-call battle)
  (if (> (lume.random 1) chance)
      (call-on-fail battle)
      (tset battle.state :text "Missile Shot Down")
      ;; (lg battle "Missile Intercepted by Rail Gun: Cost 1 Mass Ordinance")
      )
  battle)

(fn damage-support [battle hardpoint-name value]
  (db ["damage" hardpoint-name value])
  (var support nil)
  (var self-support nil)
  (each [_ hardpoint (ipairs battle.state.defensive-hardpoints)]
    (when (and hardpoint (= :table (type hardpoint.slot)) (= hardpoint-name (hardpoint:get-name)))
      (if hardpoint.free-support
          (set self-support hardpoint)
          (set support hardpoint))
      ))
  ;;(lg battle (.. "Impact prevented by " value))
  (if support
      (when support.wear-support
        ;; (lg battle (.. "Cost: " value " " (support:get-name )))
        (support:wear-support value))
      self-support
      (when self-support.wear
        ;; (lg battle (.. "Cost: " value " " (support:get-support-name)))
        (self-support:wear value)))
  battle)

(fn destroy [battle value]
  (db ["destroy" value  (# battle.state.hardpoints)])
  (let [to-destroy
        (match value
          :all (do (tset battle.state :text "All Hardpoints Destroyed!") battle.state.hardpoints)
          :one (let [target (lume.randomchoice battle.state.hardpoints)] (tset battle.state :text (.. (. translate (target:get-name)) " Destroyed!")) [target])
          _ [(do (tset battle.state :text (.. value "Destroyed!")) (choose battle.state.hardpoints value))]
          )]
    ;; (db [:to-destroy (lume.map to-destroy (fn [hardpoint] (hardpoint:get-name)))])
    (db "destroy?")
    (lume.map to-destroy (fn [hardpoint]
                           ;; (lg battle (.. (hardpoint:get-name) "Destroyed"))
                           (when (and hardpoint hardpoint.wear)
                             (hardpoint:wear 10))))
    (db "success!")
    )
  battle)

(fn sink-ship [node battle]
  (db ["sink ship"])
  (tset battle.state :text (. text node.turn :down))
  (tset battle.state :resolved true)
  (tset battle.state :success (. {:player true :enemy false} node.turn))
  (when (= :enemy node.turn) (love.handlers.hit :kill-shot))
  battle)

(fn resolve [node battle]
  (db ["resolve"])
  (local battle-state battle.state)
  ;; (battle-state.offensive:update)
  ;; (battle-state.defensive:update)
  ;; (tset battle-state :offensive-hardpoints (battle-state.offensive:get-supported-hardpoints :attack))
   ;; (tset battle-state :defenseive-hardpoints (battle-state.defensive:get-supported-hardpoints))
   (if (= :player node.turn)
       (tset node :turn :enemy)
       (tset node :turn :player))
   {:resolved battle-state.resolved :success battle-state.success :text battle-state.text :log battle-state.log}
  )

(fn resolve-missile-attack [node battle]
  (let [defensive-hardpoints battle.state.defensive-hardpoints
        hardpoints battle.state.hardpoints
        pd (has defensive-hardpoints :point-defense)
        ca (has defensive-hardpoints :ceramic-armour)
        no (none? hardpoints)]
    (resolve
     node
     (match [pd ca no]
       [_ _ true] (sink-ship node battle)
       [true true] (intercept battle 0.7 (fn [b] (damage-support b :point-defense 1))
                              (fn [b]
                                (when (= :enemy node.turn) (love.handlers.hit :missile))
                                (destroy b :ceramic-armour)))
       [true false] (intercept battle 0.7 (fn [b] (damage-support b :point-defense 1))
                               (fn [b]
                                 (when (= :enemy node.turn) (love.handlers.hit :missile))
                                 (destroy b :all)))
       [false true] (do
                      (when (= :enemy node.turn) (love.handlers.hit :missile))
                      (destroy battle :ceramic-armour))
       [false false] (do
                       (when (= :enemy node.turn) (love.handlers.hit :missile))
                       (destroy battle :all))))))

(fn resolve-railgun-attack [node battle]
  (let [defensive-hardpoints battle.state.defensive-hardpoints
        hardpoints battle.state.hardpoints
        ca (has defensive-hardpoints :ceramic-armour)
        no (none? hardpoints)]
    (db ["resolve railgun" [ca no]])
    (resolve
     node
     (match [ca no]
       [_ true]  (sink-ship node battle)
       [true _]  (do
                   (when (= :enemy node.turn) (love.handlers.hit :missile))
                   (tset battle.state :text "Ceramic Armour Hit")
                   (damage-support battle :ceramic-armour 1))
       [false _] (do
                   (when (= :enemy node.turn) (love.handlers.hit :missile))
                   (destroy battle :one))))))

(fn resolve-laser-attack [node battle]
  (let [defensive-hardpoints battle.state.defensive-hardpoints
        hardpoints battle.state.hardpoints
        sh (has defensive-hardpoints :shield)
        no (none? hardpoints)]
      (resolve
       node
       (match [sh no]
         [_ true]      (sink-ship node battle)
         [true false]  (do (tset battle.state :text "Sheild Hit")

                           (damage-support battle :shield 2))
         [false false] (do
                         (when (= :enemy node.turn) (love.handlers.hit :missile))
                         (destroy battle :one))))))

(fn resolve-no-attack [node battle]
  (tset battle.state :text (. text node.turn :none-resolve))
  (resolve node battle))

(fn battle-resolve [node battle]
  (local battle-state battle.state)
  (tset battle-state :defensive-hardpoints (battle-state.defensive:get-supported-hardpoints :defend))
  (tset battle-state :hardpoints (battle-state.defensive:get-supported-hardpoints))
  (db ["resolve-attack" battle-state.attack-name])
  (match battle-state.attack-name
    :missile-launcher (resolve-missile-attack node battle)
    :point-defense (resolve-railgun-attack node battle)
    :laser (resolve-laser-attack node battle)
    _ (resolve-no-attack node battle))
  )

(fn battle-turn-start [node battle]
  (local battle-state battle.state)
  (tset battle-state :offensive-hardpoints (battle-state.offensive:get-supported-hardpoints :attack))
  (db ["# of offensive hardpoints" (# battle-state.offensive-hardpoints)])
  (db ["offensive hardpoint names" (lume.map battle-state.offensive-hardpoints (fn [hardpoint] (hardpoint:get-name)))])
  (tset battle-state :attack (lume.randomchoice battle-state.offensive-hardpoints))
  (db ["found attack" (type battle-state.attack)])
  (if battle-state.attack
      (do
        (tset battle-state :attack-name (battle-state.attack:get-name))
        (db ["found attack name" battle-state.attack-name ])
        (tset battle-state :text (. text node.turn battle-state.attack-name))
        (db ["set text" battle-state.attack.name (. support-wear battle-state.attack-name)])
        (local cost (or (. support-wear battle-state.attack-name) 0))
        (battle-state.attack:wear-support cost)
        (db "set attach wear")
        ;; (if (= :player node.turn)
        ;;     (lg battle (.. "PLAYER LAUNCHED " battle-state.attack-name))
        ;;     (lg battle (.. "ENEMY LAUNCHED " battle-state.attack-name)))
        ;; (lg battle (..  (battle-state.attack:get-support-name) " consumed: " battle-state.attack-name)))
        )
      (tset battle-state :text (. text node.turn :none))
      )
  battle-state)

(fn battle-prep [node battle]
  (let [ship (. state :objects :ship)
        enemy-ship (. state :objects :enemy-ship)]
    (local battle-state battle.state)
    ;; (if (= :player node.turn) (lg battle "PLAYER TURN") (lg battle "ENEMY TURN"))
    (tset battle-state :defensive (if (= :enemy node.turn) ship enemy-ship))
    (tset battle-state :offensive (if (= :enemy node.turn) enemy-ship ship))
    (tset battle-state :attack-name nil)
    (tset battle-state :defensive-hardpoints nil)
    (tset battle-state :offensive-hardpoints nil)
    (tset battle-state :hardpoints nil)
    ))


(fn battle-update [dt node battle?]
  (let [short 1
        long 2
        battle (or battle? {:timer 0 :period short :step :prepare :state {:text :Prepare :resolved false :success false :log []}})
        prepare (= battle.timer 0)
        launch (and (> battle.timer short) (= :prepare battle.step))
        resolve (> battle.timer (+ short long))]
    (set battle.timer (+ dt battle.timer))
    (if prepare (do (tset battle :step :prepare) ;; 0-5 time to set attack
                    (tset battle :period short)
                     (battle-prep node battle))
        launch (do (tset battle :step :attack)  ;; 5-15 time to set defense
                   (tset battle :period long)
                   (battle-turn-start node battle))
        resolve (do (tset battle :step :prepare)  ;; reset
                    (tset battle :timer 0)
                    (tset battle :period short)
                    (tset battle :state (battle-resolve node battle))
                    ;; (pp (. battle :state :log))
                    ))
    battle
    ))
