(local ship {})

(local shared (require :ship))

(fn ship.draw [self x? y? no-outline?]
  (let [px self.pos.x
        py self.pos.y]
    (tset self.pos :x (or x? px))
    (tset self.pos :y (or y? py))
    (shared.ship-draw self)
    (tset self.pos :x  px)
    (tset self.pos :y  py)
    )
  (when (not no-outline?)
    (shared.ship-draw-outline self 80 48))
  )

(fn ship.update [self dt]
  (shared.ship-update-weapons self self.active-index))

(fn ship.get-supported-hardpoints [self mode]
  (shared.get-supported-hardpoints self mode))

(local ship-mt {:__index ship})

(fn create [atlas x y {: colliders : table}]
  (let [prefab-clickable (require :prefab-clickable)
        (quads hardpoints count)
        (shared.ship-get-quads atlas x y "Host" colliders)
        data (. shared :data "Host")
        ret {:pos {: x : y}
             :size {:w data.w :h data.h}
             :off {:x data.x :y data.y}
             ;; :type :click
             :clickable (prefab-clickable nil x y {:w data.w
                                                   :h data.h
                                                   :ox data.x
                                                   :oy data.y
                                                   : colliders
                                                   :active :click
                                                   :element :player-ship})
             : quads
             : hardpoints
             : count
             :active []
             :loadout []
             :aux []
             : table
             :image atlas.image
             }
        ]
    (setmetatable ret ship-mt)
    ;; (colliders:add ret)
    ret
    ))
