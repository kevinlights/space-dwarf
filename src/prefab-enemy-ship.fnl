(local enemy-ship {})

(local shared (require :ship))

(fn enemy-ship.draw [self]
  (love.graphics.draw self.image self.quads.ship self.pos.x self.pos.y)
  (let [slots self.table.slots]
    (each [i index (ipairs self.active-index)]
      (let [slot (. slots index)]
        (slot:draw 20 20))))
  )

(fn enemy-ship.update [self dt]
  (shared.ship-update-weapons self self.active-index))

(local enemy-ship-mt {:__index enemy-ship})

(fn create [atlas x y {: colliders : table}]
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
        (shared.ship-get-quads atlas "Yacht")
        ret {:pos {: x : y}
             :size {:w 64 :h 64}
             :type :click
             : quads
             : hardpoints
             : count
             : table
             :active-index []
             :image atlas.image
             }
        ]
    (setmetatable ret enemy-ship-mt)
    (colliders:add ret)
    ret
    ))
