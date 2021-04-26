(local table-export {})

(fn table-export.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw)))

(fn table-export.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-export-mt {:__index table-export})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :table-blue-long)
        slot1 (prefab-slot false atlas :table-export 1 (- x 1) (- y 13) colliders)
        slot2 (prefab-slot false atlas :table-export 2 (+ x 11) (- y 13) colliders)
        slot3 (prefab-slot false atlas :table-export 3 (+ x 23) (- y 13) colliders)
        slot4 (prefab-slot false atlas :table-export 4 (+ x 35) (- y 13) colliders)
        slot5 (prefab-slot false atlas :table-export 5 (+ x 47) (- y 13) colliders)
        slot6 (prefab-slot false atlas :table-export 6 (+ x 59) (- y 13) colliders)
        slot7 (prefab-slot false atlas :table-export 7 (+ x 71) (- y 13) colliders)
        slot8 (prefab-slot false atlas :table-export 8 (+ x 83) (- y 13) colliders)
        slot9 (prefab-slot false atlas :table-export 9 (+ x 95) (- y 13) colliders)
        ;; slot10 (prefab-slot :F5 atlas :table-export (+ x 107) (- y 13) colliders)
        ret {:name :table-export
             :pos {: x : y}
             :size {:w 112 :h 8}
             :off  {:x 0 :y 0}
             : quad
             :slots [slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 slot9]
             :h 12
             :w 114
             : colliders
             :type :col
             :image atlas.image}]
    (setmetatable ret table-export-mt)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 1) (- y 3) ret))
    (ret.clickable:activate "table-hold")
    (colliders:add ret)
    ret))
