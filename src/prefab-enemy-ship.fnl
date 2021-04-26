(local enemy-ship {})

(local shared (require :ship))

(fn db [text])

(fn enemy-ship.draw [self]
  (when self.quads
    (shared.ship-draw self)
    (shared.ship-draw-outline self 80 64)))

(fn enemy-ship.update [self dt]
  (when self.quads
    (shared.ship-update-weapons self self.active-index)))

(fn enemy-ship.get-supported-hardpoints [self mode]
  (shared.get-supported-hardpoints self mode))

(local ship-setups {})

(fn erase-ship [self]
  (when self.hardpoints
    (each [_ hardpoint (ipairs self.hardpoints)]
      (hardpoint:delete)))
  (each [_ slot (ipairs self.table.slots)]
    (slot:erase))
  (set self.quads false)
  )

(fn enemy-ship.set [self setup]
  (db ["make-enemy-ship" setup (. ship-setups setup)])
  (if (or (not setup) (not (. ship-setups setup)))
      (erase-ship self)
      (let [prefab-clickable (require :prefab-clickable)
            {: name : has} (. ship-setups setup)
            (quads hardpoints count)
            (shared.ship-get-quads self.atlas self.pos.x self.pos.y name self.colliders self.table)
            slots (. self.table :slots)
            data (. shared :data name)
            ret {:size {:w data.w :h data.h}
                 :off {:x data.x :y data.y}
                 : quads
                 : hardpoints
                 : count
                 }
            ]
        (when self.clickable
          (self.clickable:remove))
        (tset self :clickable (prefab-clickable nil self.pos.x self.pos.y
                                                {:w ret.size.w
                                                 :h ret.size.h
                                                 :ox ret.off.x
                                                 :oy ret.off.y
                                                 :active :click
                                                 :colliders self.colliders
                                                 :element setup}))
        (when self.hardpoints
          (each [_ hardpoint (ipairs self.hardpoints)]
            (hardpoint:delete)))
        (each [_ slot (ipairs slots)]
          (slot:erase))
        (each [i value (ipairs has)]
          (let [slot (. slots i)]
            (db ["slot make" value])
            (slot:make value)))
        (each [key value (pairs ret)]
          (tset self key value))
        (self.colliders:update self)
        ret
        )))

(local enemy-ship-mt {:__index enemy-ship})

(fn create [atlas x y {: colliders : table : setup}]
  (let [ret {:pos {: x : y}
             :size {:w 0 :h 0}
             :type :click
             : table
             : colliders
             : atlas
             :image atlas.image
             : ship-setups
             }
        ]
    (setmetatable ret enemy-ship-mt)
    (when setup (ret:set setup))
    ret
    ))
