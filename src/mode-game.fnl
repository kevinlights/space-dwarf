(local state (require :state))

(local game {})

(fn draw-background [self]
  (love.graphics.draw assets.sprites.Background 0 0 0)
  (love.graphics.draw assets.sprites.Background 0 -220 0))

(fn draw-game [self]
  (when (> state.hit-timer 0)
    (love.graphics.setColor 1 0 0 1)
    (love.graphics.translate (math.random 3) (math.random 3)))
    (love.graphics.push)

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
  (state.objects.console:draw))

(var title-font (assets.fonts.fffforwa (* 15 scale)))
(title-font:setLineHeight 1.2)
(var text-font (assets.fonts.inconsolata (* 10 scale)))
(var footer-font (assets.fonts.inconsolata (* 5 scale)))

(fn draw-game-over []
  (love.graphics.setColor params.colours.blue)
  (love.graphics.rectangle "fill" 0 0 (* scale 400) (* scale 220))
  (love.graphics.setFont title-font)
  (love.graphics.setColor params.colours.black)
  (love.graphics.printf "Welcome my Good Dwarf,\nWe have Been Expecting You" 0 (* scale 80) (* scale 400) :center)
  (love.graphics.setFont text-font)
  (love.graphics.printf "Press Escape to Exit" 0 (* scale 140) (* scale 400) :center)
  (love.graphics.setFont footer-font)
  (love.graphics.printf "Game, Art and Music by AlexJGriffith" 0 (* scale 210) (* scale 395) :right)
  )

(fn game.draw [self]
  (if (not state.game-over)
      (draw-game self)
      (draw-game-over)
      )
  (when state.print-debug
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.setFont text-font)
    (love.graphics.printf "test 0.2.1" 10 10 200)
    )
  )

(fn game.update [self dt]
  (each [key obj (pairs state.objects)]
    (obj:update dt))
  (when state.init (state.fire:setVolume 0))
  (tset state :hit-timer (- state.hit-timer dt))
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

(fn cheat []
  (let [slots state.objects.table-hold.slots
        slot1 (. slots 1)
        slot2 (. slots 2)
        slot3 (. slots 3)
        slot4 (. slots 4)
        slot5 (. slots 5)
        slot6 (. slots 6)
        slot7 (. slots 7)
        slot8 (. slots 8)]
    (slot1:make :ceramic-armour)
    (slot2:make :point-defense)
    (slot3:make :mass-ordinance)
    (slot4:make :capacitor)
    (slot5:make :laser)
    (slot6:make :shield)
    (slot7:make :missile-launcher)
    (slot8:make :missile)
    )
)

(fn game.keypressed [self key]
  (when state.game-over
    (match key
      :escape (love.event.quit)))
  (match (state.objects.player:keypressed key)
    :i (if state.objects.starfield.warping
         (state.objects.starfield:fight)
         (state.objects.starfield:warp))
    :/ (cheat)
    :m (toggle-sound)
    :1 (state.objects.node:set :asteroid-2 1)
    :2 (state.objects.node:set :transport 2)
    :3 (state.objects.node:set :pirate-2 3)
    :4 (state.objects.node:set :drone-2 4)
    :5 (state.objects.node:set :diplomat-1 5)
    :6 (state.objects.node:set :diplomat-2 6)
    :7 (state.objects.node:set :corvette-2 7)
    :8 (do (state.objects.node:set :cruiser-2 8) )
    ))

(fn game.mousepressed [self x y button]
  (let [colliders (. (require :state) :colliders)]
    (colliders:check-point x y :click)
    )
  )

(fn game.mousereleased [self x y button]
  (tset (require :state) :drag false))

game
