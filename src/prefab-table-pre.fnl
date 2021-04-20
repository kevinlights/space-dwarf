(local table-pre {})

(fn table-pre.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw)))

(fn table-pre.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-pre-mt {:__index table-pre})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :table-blue-3)
        slot1 (prefab-slot false atlas :table-pre 1 (+ x 4) (- y 13) colliders)
        slot2 (prefab-slot false atlas :table-pre 2 (+ x 16) (- y 13) colliders)
        slot3 (prefab-slot false atlas :table-pre 3 (+ x 28) (- y 13) colliders)
        ret {:name :table-pre
             :pos {: x : y}
             :size {:w 40 :h 8}
             :off  {:x 5 :y 0}
             : quad
             :slots [slot1 slot2 slot3]
             :type :col
             :image atlas.image}]
    (setmetatable ret table-pre-mt)
    (colliders:add ret)
    ret))
