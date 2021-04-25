(local state (require :state))

(local game {})

(fn draw-background [self]
  (love.graphics.draw assets.sprites.Background 0 0 0)
  (love.graphics.draw assets.sprites.Background 0 -220 0))

(fn game.draw [self]
  (love.graphics.push "all")

  (love.graphics.scale scale)
  (state.objects.starfield:draw)
  (state.objects.console:move)
  (when (not state.init)
    (draw-background)
    (local player state.objects.player)
    (each [key value (pairs state.objects)]
      (when (and
             (~= :console value.name)
             (~= :starfield value.name)
             (~= :player value.name) (>= (+ player.pos.y player.off.y player.size.h)
                                         (+ value.pos.y (if value.off value.off.y 0) value.size.h)))
        (value:draw))
      )
    (player:draw)
    (each [key value (pairs state.objects)]
      (when (and
             (~= :console value.name)
             (~= :starfield value.name)
             (~= :player value.name) (< (+ player.pos.y player.off.y player.size.h)
                                        (+ value.pos.y (if value.off value.off.y 0) value.size.h)))
        (value:draw))
      )
    )


  ;; (when state.init
  ;;   )
  ;; (state.colliders:draw :click)
  ;;
  (love.graphics.pop)
  (state.objects.console:draw)
  )

(fn game.update [self dt]
  (each [key obj (pairs state.objects)]
    (obj:update dt))
  (when (not false) (collectgarbage)))

(fn game.init [arg1 arg2]
  (local prefab-colliders (require :prefab-colliders))
  (local prefab-player (require :prefab-player))
  (tset state :colliders (prefab-colliders.create))
  (tset state :objects {})
  ;; (tset state :objects :player (prefab-player))
  ;; (state.colliders:add state.objects.player)
  (local load-objects (require :load-objects))
  (load-objects)
  (let [console (. state :objects :console)]
    (console:center))
  )

(fn game.wheelmoved [self x y]
  (match (. state :objects :console)
    nil nil
    console (console:wheelmoved x y)
    ))

(fn game.keypressed [self key]
  (pp key)
  (match (state.objects.player:keypressed key)
    :i (if state.objects.starfield.warping
         (state.objects.starfield:fight)
         (state.objects.starfield:warp))))

(fn game.mousepressed [self x y button]
  (let [colliders (. (require :state) :colliders)]
    (colliders:check-point x y :click)
    )
  )

(fn game.mousereleased [self x y button]
  (tset (require :state) :drag false))

game
