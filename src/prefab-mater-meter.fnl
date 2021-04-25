(local mater-meter {})

(fn mater-meter.draw [self]
  (love.graphics.setColor params.colours.blue)
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (love.graphics.setColor params.colours.red)
  (love.graphics.draw self.image self.trimmed-quad self.pos.x self.pos.y)
  (love.graphics.setColor 1 1 1 1)
  )

(fn mater-meter.update [self dt]
  (self.trimmed-quad:setViewport self.off.x self.off.y self.size.w (* (- 1 (/ self.value self.max)) self.size.h)))

(fn mater-meter.change [self value]
  (set self.value (lume.clamp (+ self.value value) 0 self.max)))

(local mater-meter-mt {:__index mater-meter})

(fn create [atlas x y _args]
  (let [quad (. atlas :quads "Blocks.aseprite" :mater-meter)
        (qx qy w h) (quad:getViewport)
        (sh sw) (quad:getTextureDimensions)
        ret {:name :mater-meter
             :pos {: x : y}
             :size {:w w :h h}
             :off {:x qx :y qy}
             : quad
             :trimmed-quad (love.graphics.newQuad qx qy w h sh sw)
             :value 2
             :max 100
             :image atlas.image}]
    (setmetatable ret mater-meter-mt)
    ret))
