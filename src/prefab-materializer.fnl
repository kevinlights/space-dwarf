(local materializer {})

(fn materializer.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw))
  (love.graphics.draw self.image self.top-quad self.pos.x self.pos.y)
  )

(fn materializer.update [self dt]
  (let [slot (. self :slots 1)]
    (when (= false (. slot :filled-with))
      (tset self :timer (+ self.timer dt))
      (when (> self.timer self.period)
        (tset self :timer 0)
        (slot:set :MA))
      ))
  (each [_ slot (pairs self.slots)] (slot:update dt))
  )

(local materializer-mt {:__index materializer})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :MT1)
        top-quad (. atlas :quads "Blocks.aseprite" :MT2)
        slot1 (prefab-slot :MA atlas :furnace 1 (+ x 2) (+ y 10) colliders)
        ret {:name :materializer
             :pos {: x : y}
             :size {:w 16 :h 12}
             :off  {:x 0 :y 20}
             : quad
             : top-quad
             :timer 0
             :period 1
             :slots [slot1]
             :type :col
             :h 28
             :w 24
             : colliders
             :image atlas.image}]
    (setmetatable ret materializer-mt)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 2) (- y 16) ret))
    (ret.clickable:activate "MT")
    (colliders:add ret)
    ret))
