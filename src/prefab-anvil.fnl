(local anvil {})

(fn anvil.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw)))

(fn anvil.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local anvil-mt {:__index anvil})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :AN)
        slot1 (prefab-slot false atlas :anvil 1 (+ x 6) (- y 10) colliders)
        ret {:name :anvil
             :pos {: x : y}
             :size {:w 20 :h 8}
             :off  {:x 4 :y 8}
             : quad
             :slots [slot1]
             :type :col
             : colliders
             :h 16
             :w 24
             :image atlas.image}]
    (setmetatable ret anvil-mt)
    ;;(colliders:add ret)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 2) (- y 5) ret))
    (ret.clickable:activate "AN")
    (colliders:add ret)
    ret))
