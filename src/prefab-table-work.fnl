(local table-work {})

(fn table-work.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw)))

(fn table-work.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-work-mt {:__index table-work})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :table-blue-1)
        slot1 (prefab-slot false atlas :table-work 1 (- x 1) (- y 12) colliders)
        ret {:name :table-work
             :pos {: x : y}
             :size {:w 8 :h 8}
             :off  {:x 4 :y 2}
             : quad
             :slots [slot1]
             :type :col
             :h 12
             :w 10
             : colliders
             :image atlas.image}]
    (setmetatable ret table-work-mt)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 1) (- y 3) ret))
    (ret.clickable:activate "table-work")
    (colliders:add ret)
    ret))
