(local furnace {})

(fn furnace.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (love.graphics.draw self.image (. self.fire self.fire-index) (+ 7 self.pos.x) (+ 9 self.pos.y))
  (love.graphics.draw self.image self.top-quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw))
  )

(fn furnace.update [self dt]
  ;; fire render update
  (tset self :timer (+ dt self.timer))
  (when (< self.fire-period self.timer)
    (tset self :fire-index (+ self.fire-index 1))
    (when (> self.fire-index (# self.fire))
      (tset self :fire-index 1))
    (tset self :timer 0)
    )
  ;; heat slots
  (each [_ slot (pairs self.slots)]
    (slot:update dt {:rate self.rate})
  ))

(local furnace-mt {:__index furnace})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :FR1)
        top-quad (. atlas :quads "Blocks.aseprite" :FR2)
        fire (lume.map [:Fire1 :Fire2 :Fire3 :Fire4] (fn [slice] (. atlas :quads "Blocks.aseprite" slice)))
        slot1 (prefab-slot false atlas :furnace 1 (+ x 1) (+ y 11) colliders)
        slot2 (prefab-slot false atlas :furnace 2 (+ x 10) (+ y 11) colliders)
        ret {:name :furnace
             :pos {: x : y}
             :size {:w 32 :h 32}
             : quad
             :fire fire
             :fire-period 0.2
             :fire-index 1
             :timer 0
             : top-quad
             :rate 100
             :type :col
             :slots [slot1 slot2]
             :image atlas.image}]
    (setmetatable ret furnace-mt)
    (colliders:add ret)
    ret))
