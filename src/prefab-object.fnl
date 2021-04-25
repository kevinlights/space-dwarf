(local object {})

(local colliders (. (require :state) :colliders))

(fn object.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y))

(fn object.update [self dt])

(local object-mt {:__index object})

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
