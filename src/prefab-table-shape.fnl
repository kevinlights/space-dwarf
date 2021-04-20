(local table-shape {})

(fn table-shape.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw)))

(fn table-shape.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-shape-mt {:__index table-shape})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :table-blue-4)
        slot1 (prefab-slot :F1 atlas :table-shape 1 (- x 1) (- y 13) colliders)
        slot2 (prefab-slot :F2 atlas :table-shape 2 (+ x 11) (- y 13) colliders)
        slot3 (prefab-slot :F3 atlas :table-shape 3 (+ x 23) (- y 13) colliders)
        slot4 (prefab-slot :F4 atlas :table-shape 4 (+ x 35) (- y 13) colliders)
        slot5 (prefab-slot :F5 atlas :table-shape 5 (+ x 47) (- y 13) colliders)
        ret {:name :table-shape
             :pos {: x : y}
             :size {:w 64 :h 8}
             :off  {:x 0 :y 0}
             : quad
             :slots [slot1 slot2 slot3 slot4 slot5]
             :type :col
             :image atlas.image}]
    (setmetatable ret table-shape-mt)
    (colliders:add ret)
    ret))
