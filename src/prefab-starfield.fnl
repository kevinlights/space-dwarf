(local starfield {})

(local state (require :state))

(fn starfield.update [self dt]
  (self.part:update dt))

(fn starfield.draw [self]
  ;; (love.graphics.push "all")
  ;; (love.graphics.setColor 1 1 1 1)
  ;; (love.graphics.setCanvas self.canvas)
  ;; (love.graphics.clear 1 1 1 0)
  (love.graphics.draw self.part 0 0)
  ;; (love.graphics.setCanvas)
  ;;(love.graphics.pop)
  ;; self.canvas
  )

(fn ff [self frames]
    (for [_i 1 frames]
      (self.part:update 0.0166)))

(local starfield-mt {:__index starfield
                :update starfield.update
                :draw starfield.draw})

(fn setup-part [starfield-canvas]
  (local part (love.graphics.newParticleSystem starfield-canvas (if state.web 300 5000)))
  ;;(part:setParticleLifetime 0.5 1)
  ;;(part:setEmissionRate 50000)
  ;;(part:setSizeVariation 0.3)
  ;;(part:setSpeed 1000 2000)
  ;;(part:setSpin 0.1 1)
  ;;(part:setSpread 0.1)
  ;;(part:setEmissionArea :uniform 1280 1280)

  (part:setDirection (/ math.pi 2))
  ;; (part:setLinearAcceleration -20 -20 20 20)
  (part:setRotation -1 1)
  (part:setColors 1 1 1 1 1 1 1 0)
  part
)

(fn starfield.fight [self]
  (local part self.part)
  (part:setEmissionArea :uniform 400 400)
  (part:setParticleLifetime 0.5 1)
  (part:setEmissionRate 5000)
  (part:setSizeVariation 1)
  ;;(part:setSpeed 50 75)
  (part:setSpeed 0 0)
  (part:setSizes 0 3)
  (part:setSpin 0.1 1)
  ;; (ff self 200)
  (tset self :warping false)
  )

(fn starfield.warp [self]
  (local part self.part)
  (part:setParticleLifetime 0.5 1)
  (part:setEmissionRate 50000)
  (part:setSizeVariation 0.3)
  (part:setSpeed 300 700)
  (part:setSpin 0.1 1)
  (part:setSizes 0 1 3 10)
  (part:setEmissionArea :ellipse 20 20)
  (part:setPosition 190 110)
  (part:setSpread (* 2 math.pi))
  (ff self 200)
  (tset self :warping true)
  )

(fn starfield.replace-part [self]
  (tset self :part (setup-part self.starfield-canvas)))

(fn create [atlas x y {: s : n}]
  (local starfield-canvas (love.graphics.newCanvas 4 4))
  ;; (local canvas (love.graphics.newCanvas (* scale 400) (* scale 220)))
  (local quad (. atlas :quads "Blocks.aseprite" :star))
  (love.graphics.push "all")
  (love.graphics.setCanvas starfield-canvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw atlas.image quad)
  (love.graphics.setCanvas)
  (love.graphics.pop)
  (local part (setup-part starfield-canvas))
  (local ret (setmetatable {:pos {: x : y}
                            :size {:w 0 :h 0}
                            :name :starfield
                            ;; : canvas
                            :image atlas.image
                            :quad quad
                            :warping false
                            : s
                            : n
                            : part
                            : starfield-canvas
                            } starfield-mt))
  (ff ret 200)
  (ret:warp)

  ret)
