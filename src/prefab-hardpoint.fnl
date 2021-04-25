(local hardpoint {})

(fn hardpoint.draw [self]
  (when self.slot
    (self.slot:draw (+  -9 (- self.pos.x  self.dx))
               (+  -15 (-  self.pos.y self.dy))
               true)
      ))

(fn hardpoint.update [self dt])

(fn hardpoint.set-index [self slot]
  (tset self :slot slot)
  (if slot
      (self.clickable:activate slot.filled-with)
      (self.clickable:deactivate)))

(fn hardpoint.delete [self]
  (self.clickable:remove self))

(local hardpoint-mt {:__index hardpoint})

(fn create [atlas x y {: colliders : dx : dy}]
  (let [prefab-clickable (require :prefab-clickable)
        ret {:pos {: x : y}
             : dx
             : dy
             :size {:w 10 :h 10}
             :off {:x (- (+ dx 5)) :y (- (+ dy 8))}
             :slot false
             ;;: colliders
             :clickable (prefab-clickable nil x y {:w 10 :h 10
                                                   :ox (- (+ dx 5)) :oy (- (+ dy 8))
                                                   :type :inactive
                                                   : colliders
                                                   :element false})
             }]
    (setmetatable ret hardpoint-mt)
    ;; (colliders:add ret)
    ret
  ))
