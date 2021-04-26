(local data
       {:Host {:w 48 :h 32 :x 8 :y 0}
        :Asteroids {:w 48 :h 44 :x 8 :y 4}
        :Corvette {:w 48 :h 48 :x 8 :y 8}
        :Sloop {:w 32 :h 32 :x 16 :y 16}
        :Transport {:w 48 :h 48 :x 10 :y 6}
        :Yacht {:w 48 :h 32 :x 8 :y 8}
        :Cruiser {:w 62 :h 48 :x 2 :y 16}
        :Drone {:w 32 :h 32 :x 21 :y 16}})

(fn db [text])

(fn ship-draw [ship]
  (love.graphics.push "all")

  (love.graphics.draw ship.image ship.quads.ship ship.pos.x ship.pos.y)
  (let [slots ship.table.slots
        (dx dy) (ship.quads.ship:getViewport)]
    (each [i hardpoint (ipairs ship.hardpoints)]
      (when hardpoint.slot
        (love.graphics.draw ship.image (. ship.quads.guns i) ship.pos.x ship.pos.y)
        (when (not (hardpoint:supported)) (love.graphics.setColor 0.8 0.1 0.1 1))
        ;; (db ["free-support" hardpoint.free-support])
        (love.graphics.draw ship.image (. ship.quads.icons i) ship.pos.x ship.pos.y)
        (love.graphics.setColor 1 1 1 1)
        (hardpoint:draw))
      ))
  (love.graphics.pop)
  )
(fn ship-draw-outline [ship w h]
  (let [{: x : y} ship.pos]
    (love.graphics.line x y (+ x 2) y)
    (love.graphics.line x y (+ x 0) (+ y 2))
    (love.graphics.line (+ x 0) (+ y h) (+ x 2) (+ y h))
    (love.graphics.line (+ x 0) (+ y h) (+ x) (+ y h -2))

    (love.graphics.line (+ x w) y (+ x -2 w) y)
    (love.graphics.line (+ w x) y (+ x w) (+ y 2))
    (love.graphics.line (+ x w) (+ y h) (+ x w -2) (+ y h))
    (love.graphics.line (+ x w) (+ y h) (+ x w) (+ y h -2))
    )
  )

(fn ship-get-quads [atlas x y slice colliders]
  (fn parse [str dx dy]
    (let [ret []
          prefab-hardpoint (require :prefab-hardpoint)]
      (each [value i (string.gmatch str "[0-9]+,[0-9]+,[0-9]+")]
        (let [mid []]
          (each [v i (string.gmatch value "[0-9]+")]
            (table.insert mid (tonumber v)))
          (tset ret (. mid 1)
                (prefab-hardpoint atlas (+ x (. mid 2)) (+ y (. mid 3)) {: colliders : dx : dy})))) ret))
  (let [ship-quad (. atlas :quads "Ships (Ships).aseprite" slice)
        (dx dy) (ship-quad:getViewport)
        hardpoints (parse (. atlas :info slice) dx dy)
        count (# hardpoints)
        quads {:ship ship-quad
               :guns []
               :icons []}
        ]
    (for [i 1 count]
      (tset quads.guns i (. atlas :quads (.. "Ships (Gun" i ").aseprite") slice))
      (tset quads.icons i  (. atlas :quads (.. "Ships (Icon" i ").aseprite") slice)))
      (values quads hardpoints count)))

(fn ship-update-weapons [ship]
  (let [count ship.count
        slots ship.table.slots
        options (lume.invert [:laser :point-defense :ceramic-armour :missile-launcher
                              :shield])
        aux (lume.invert [:missile :mass-ordinance :capacitor])
        all (lume.invert [:laser :point-defense :ceramic-armour :missile-launcher
                          :shield :missile :mass-ordinance :capacitor])
        supports {:laser :capacitor :point-defense :mass-ordinance :ceramic-armour true :missile-launcher :missile :shield :capacitor}
        fun (fn filter-slots [options]
              (-> slots
                  (lume.map (fn [slot] (slot:complete? options)))
                  (lume.filter (fn [slot] slot))
                  (lume.map (fn [slot] (. slot :container :build)))
                  ))
        ]
    ;; (set active [])
    ;; (lume.clear active)
    (set ship.loadout [])
    (var aux-slots {})
    (each [_ slot (ipairs slots)]
      (when (< slot.wear 1)
        (slot:erase))
      (when (and (= :finished slot.category) (. aux slot.container.build))
        (tset aux-slots slot.container.build slot)))

    (for [i 1 count]
      (let [hardpoint (. ship.hardpoints i)]
        (hardpoint:set-index false)))
    (var i 1)
    (each [_ slot (ipairs slots)]
      (when (and (= :finished slot.category) (. options slot.container.build) (<= i count))
        (let [hardpoint (. ship.hardpoints i)]
          (hardpoint:set-index slot)
          ;; (db ["supports" slot.container.build (. supports slot.container.build) ])
          (let [depends-on (. supports slot.container.build)]
            (match (type depends-on)
              :boolean (do (tset hardpoint :free-support true)
                           (tset hardpoint :support-slot false)
                           (table.insert ship.loadout slot.container.build)
                           )
              :string (do
                        (tset hardpoint :free-support false)
                        (tset hardpoint :support-slot (or (. aux-slots depends-on) false))
                        (table.insert ship.loadout slot.container.build))
              :nil (do (tset hardpoint :free-support false)
                        (tset hardpoint :support-slot false)))
            )
          (hardpoint.clickable:activate (slot.container:name))
          (hardpoint.clickable:update 0))
        (set i (+ i 1))
        )
      )

    (set ship.active (filter-slots all))

    ;; (set ship.loadout (lume.slice (lume.filter ship.active (fn [active] (. options active))) 3))
    ;; (set ship.aux (lume.filter ship.active (fn [active] (. aux active))))
    ))


(fn get-supported-hardpoints [ship mode]
  (let [offensive (lume.invert [:point-defense :laser :missile-launcher])
        defensive (lume.invert [:point-defense :shield :ceramic-armour])]
    (match mode
      :attack (lume.filter ship.hardpoints (fn [hardpoint] (and (= (type hardpoint.slot) :table) hardpoint.slot.filled-with (hardpoint:supported) (. offensive (hardpoint:get-name)))))
      :defend (lume.filter ship.hardpoints (fn [hardpoint] (and (= (type hardpoint.slot) :table) hardpoint.slot.filled-with (hardpoint:supported) (. defensive (hardpoint:get-name)))))
      _ (lume.filter ship.hardpoints (fn [hardpoint] (and (= (type hardpoint.slot) :table) hardpoint.slot.filled-with (> hardpoint.slot.wear 0))))))
  )

{: ship-get-quads : ship-update-weapons : ship-draw : data : ship-draw-outline : get-supported-hardpoints}
