(local object {})

(local colliders (. (require :state) :colliders))

(fn object.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y))

(fn object.update [self dt])

(local object-mt {:__index object})

(local properties {:AN {:size {:w 20 :h 8}
                        :off  {:x 4 :y 8}}
                   :mt1 {:size {:w 16 :h 12}
                         :off  {:x 0 :y 20}}
                   :FR1 {:size {:w 32 :h 32}
                         }
                   }
       )

(fn create [atlas slice x y]
  (let [quad (. atlas :quads "Blocks.aseprite" slice)

        prop (. properties slice)
        size (if prop (. prop :size) (. atlas :size slice))
        off (when prop (. properties slice :off))
        ]

    (local ret {:pos {: x : y}
                :size size
                :off off
                : quad
                :image atlas.image})
    (setmetatable ret object-mt)
    (if prop (colliders:add ret))
    ret
  ))
