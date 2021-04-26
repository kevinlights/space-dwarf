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

(fn hardpoint.wear [self value]
  (set self.slot.wear (- self.slot.wear value)))

(fn hardpoint.wear-support [self value]
  (when self.support-slot
    (set self.support-slot.wear (- self.support-slot.wear value))))

(fn hardpoint.get-name [self]
  (when (and self.slot (= :table (type self.slot)))
    self.slot.container.build))

(fn hardpoint.get-support-name [self]
  (if self.free-support
      (self:get-name)
      (and self.support-slot (= :table (type self.support-slot)))
      self.support-slot.container.build))

(fn hardpoint.supported [self]
  (or self.free-support self.support-slot))

(fn hardpoint.delete [self]
  (self.clickable:remove self))

(local hardpoint-mt {:__index hardpoint})

(fn create [atlas x y {: colliders : dx : dy}]
  (let [prefab-clickable (require :prefab-clickable)
        ret {:pos {: x : y}
             : dx
             : dy
             :name :hardpoint
             :size {:w 10 :h 10}
             :off {:x (- (+ dx 5)) :y (- (+ dy 8))}
             :slot false
             :free-support false
             :support-slot false
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
