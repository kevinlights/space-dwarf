(local enemy-ship {})

(local shared (require :ship))

(fn enemy-ship.draw [self]
  (shared.ship-draw self))

(fn enemy-ship.update [self dt]
  (shared.ship-update-weapons self self.active-index))

(local enemy-ship-mt {:__index enemy-ship})

(fn enemy-ship.set [self name]
  (let [(quads hardpoints count)
        (shared.ship-get-quads self.atlas self.pos.x self.pos.y name self.colliders self.table)
        data (. shared :data name)
        ret {:size {:w data.w :h data.h}
             :off {:x data.x :y data.y}
             : quads
             : hardpoints
             : count
             :active-index []
             }
        ]
    (each [key value (pairs ret)]
      (tset self key value))
    (self.colliders:update self)
    ret
  ))

(fn create [atlas x y {: colliders : table : name}]
  (let [slots (. table :slots)
        slot-1 (. slots 1)
        slot-2 (. slots 2)
        slot-3 (. slots 3)
        slot-4 (. slots 4)
        slot-5 (. slots 5)]
    (slot-1:make :laser)
    (slot-2:make :sheild)
    (slot-3:make :capacitor)
    (slot-4:make :point-defense)
    (slot-5:make :mass-ordinance)
    )
  (let [(quads hardpoints count)
        (shared.ship-get-quads atlas x y "Drone" colliders table)
        data (. shared :data "Drone")
        ret {:pos {: x : y}
             :size {:w data.w :h data.h}
             :off {:x data.x :y data.y}
             :type :click
             : quads
             : hardpoints
             : count
             : table
             : colliders
             : atlas
             :image atlas.image
             }
        ]
    (setmetatable ret enemy-ship-mt)
    (colliders:add ret)
    ret
    ))
