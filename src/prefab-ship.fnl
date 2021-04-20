(local ship {})

(local shared (require :ship))

(fn ship.draw [self]
  (shared.ship-draw self))

(fn ship.update [self dt]
  (shared.ship-update-weapons self self.active-index))

(local ship-mt {:__index ship})

(fn create [atlas x y {: colliders : table}]
  (let [(quads hardpoints count)
        (shared.ship-get-quads atlas x y "Host" colliders)
        data (. shared :data "Host")
        ret {:pos {: x : y}
             :size {:w data.w :h data.h}
             :off {:x data.x :y data.y}
             :type :click
             : quads
             : hardpoints
             : count
             : table
             :image atlas.image
             }
        ]
    (setmetatable ret ship-mt)
    (colliders:add ret)
    ret
    ))
