(local state (require :state))

(local game {})

(fn draw-background [self]
  (love.graphics.draw assets.sprites.Background 0 0 0)
  (love.graphics.draw assets.sprites.Background 0 -220 0))

(fn game.draw [self]
  (love.graphics.push "all")
  (love.graphics.scale 3)
  (draw-background)
  ;; (state.colliders:draw)
  (each [key value (pairs state.objects)]
    (value:draw))
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
  (tset state :objects :player (prefab-player))
  (state.colliders:add state.objects.player)
  ((require :load-objects))
  )

game
