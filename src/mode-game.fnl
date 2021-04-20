(local state (require :state))

(local game {})

(fn draw-background [self]
  (love.graphics.draw assets.sprites.Background 0 0 0)
  (love.graphics.draw assets.sprites.Background 0 -220 0))

(fn game.draw [self]
  (love.graphics.push "all")
  (love.graphics.scale scale)
  (draw-background)

  (local player state.objects.player)
  (each [key value (pairs state.objects)]
    (when (and (~= :player value.name) (>= (+ player.pos.y player.off.y player.size.h)
                                          (+ value.pos.y (if value.off value.off.y 0) value.size.h)))
      (value:draw))
    )
  (player:draw)
  (each [key value (pairs state.objects)]
    (when (and (~= :player value.name) (< (+ player.pos.y player.off.y player.size.h)
                                          (+ value.pos.y (if value.off value.off.y 0) value.size.h)))
      (value:draw))
    )
  (state.colliders:draw :click)
  (love.graphics.pop)
  )

(fn game.update [self dt]
  (each [key obj (pairs state.objects)]
    (obj:update dt)))

(fn game.init [arg1 arg2]
  (local prefab-colliders (require :prefab-colliders))
  (local prefab-player (require :prefab-player))
  (tset state :colliders (prefab-colliders.create))
  (tset state :objects {})
  ;; (tset state :objects :player (prefab-player))
  ;; (state.colliders:add state.objects.player)
  (local load-objects (require :load-objects))
  (load-objects)
  )

(fn game.keypressed [self key]
  (state.objects.player:keypressed key))

game
