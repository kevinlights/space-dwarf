(local etcher {})

(fn etcher.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw))
  (love.graphics.draw self.image self.top-quad self.pos.x self.pos.y)
  )

(fn etcher.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt {:pos self.pos :offset {:x -1 :y (+ -2 (. self.bounce (+ 1 self.bounce-index)))}}))
  (let [slot (. self :slots 1)]
    (if slot.filled-with
        (do (tset self :transform-timer (+ self.transform-timer dt))
            (tset self :bounce-timer (+ self.bounce-timer dt))
            (when (and self.transform-timer (> self.transform-timer self.transform-period))
              (slot:etch)
              )
            (when (> self.bounce-timer self.bounce-period)
              (tset self :bounce-timer 0)
              (tset self :bounce-index (% (+ 1 self.bounce-index) (# self.bounce))))
            )
        (do
          (tset self :transform-timer 0)
          (tset self :bounce-timer 0)
          (tset self :bounce-index 1))
      )
    )  )

(local etcher-mt {:__index etcher})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :ET)
        top-quad (. atlas :quads "Blocks.aseprite" :ET2)
        slot1 (prefab-slot false atlas :etcher 1 (- x 1) (- y 2) colliders)
        ret {:name :etcher
             :pos {: x : y}
             :size {:w 8 :h 8}
             :off  {:x 4 :y 8}
             : quad
             : top-quad
             :bounce-period 0.2
             :bounce-index 0
             :bounce  [-4 -3 -2 -2 -3 -4]
             :bounce-timer 0
             :transform-period 1
             :transform-timer 0
             :slots [slot1]
             :type :col
             :h 10
             :w 10
             : colliders
             :image atlas.image}]
    (setmetatable ret etcher-mt)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 1) (- y 3) ret))
    (ret.clickable:activate "etcher")
    (colliders:add ret)
    ret))
