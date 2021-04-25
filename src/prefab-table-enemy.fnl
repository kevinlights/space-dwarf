(local table-enemy {})

(fn table-enemy.draw [self]
  ;;(love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  ;; (each [_ slot (ipairs self.slots)] (slot:draw nil nil true))
  )

(fn table-enemy.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-enemy-mt {:__index table-enemy})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :table-red-long)
        slot1 (prefab-slot false atlas :table-enemy 1 (- x 1) (- y 13) colliders)
        slot2 (prefab-slot false atlas :table-enemy 2 (+ x 11) (- y 13) colliders)
        slot3 (prefab-slot false atlas :table-enemy 3 (+ x 23) (- y 13) colliders)
        slot4 (prefab-slot false atlas :table-enemy 4 (+ x 35) (- y 13) colliders)
        slot5 (prefab-slot false atlas :table-enemy 5 (+ x 47) (- y 13) colliders)
        slot6 (prefab-slot false atlas :table-enemy 6 (+ x 59) (- y 13) colliders)
        slot7 (prefab-slot false atlas :table-enemy 7 (+ x 71) (- y 13) colliders)
        slot8 (prefab-slot false atlas :table-enemy 8 (+ x 83) (- y 13) colliders)
        slot9 (prefab-slot false atlas :table-enemy 9 (+ x 95) (- y 13) colliders)
        ret {:name :table-enemy
             :pos {: x : y}
             :size {:w 112 :h 8}
             :off  {:x 0 :y 0}
             : quad
             :slots [slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 slot9]
             :type :col
             :image atlas.image}]
    (setmetatable ret table-enemy-mt)
    (colliders:add ret)
    ret))
