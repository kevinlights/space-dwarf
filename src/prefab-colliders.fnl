(local colliders {})

(local bump (require :lib.bump))

(fn colliders.draw [self]
  (local (items len) (self.world:getItems))
  (each [_ item (ipairs items)]
    (if item.off
        (love.graphics.rectangle "line"
                                 (+ item.pos.x item.off.x)
                                 (+ item.pos.y item.off.y)
                                 item.size.w item.size.h)
        (love.graphics.rectangle "line" item.pos.x item.pos.y item.size.w item.size.h))))

(fn colliders.add [self {:pos {:x x :y y} :size {:w w :h h} :off off &as value}]
  (if off
      (self.world:add value (+ x off.x) (+ y off.y)  w h)
      (self.world:add value x y w h)))

(local colliders-mt {:__index colliders})

(fn create []
  (local ret {})
  (tset ret :world (bump.newWorld 64))
  ;; add main borders
  (tset ret :bounds {:top    {:name :top :type :col
                              :pos {:x 32 :y 150}
                              :size {:w 336 :h 10}}
                     :bottom {:name :bottom :type :col
                              :pos {:x 32 :y 208}
                              :size {:w 336 :h 8}}
                     :left   {:name :left :type :col
                              :pos {:x 22 :y 150}
                              :size {:w 10 :h 66}}
                     :right  {:name :right :type :col
                              :pos {:x 368 :y 150}
                              :size {:w 10 :h 66}}
                          })
  (setmetatable ret colliders-mt)
  (each [key value (pairs ret.bounds)]
    (ret:add value))
  ret
  )

{: create}
