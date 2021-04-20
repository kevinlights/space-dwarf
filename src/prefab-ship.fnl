(local ship {})

(local shared (require :ship))

(fn ship.draw [self]
  (love.graphics.draw self.image self.quads.ship self.pos.x self.pos.y)
  )

(fn ship.update [self dt])

(local ship-mt {:__index ship})

(fn create [atlas x y {: colliders : type}]
  (let [(quads hardpoints count)
        (shared.ship-get-quads atlas "Host")
        ret {:pos {: x : y}
             :size {:w 64 :h 64}
             :type :click
             : quads
             : hardpoints
             : count
             :active-index []
             :image atlas.image
             }
        ]
    (setmetatable ret ship-mt)
    (colliders:add ret)
    ret
    ))
