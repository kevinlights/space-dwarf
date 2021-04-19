(local player {})

(local anim8 (require :lib.anim8))

(fn load-animations [player]
  (local g (anim8.newGrid 16 16
                          (assets.sprites.Dwarf:getWidth)
                          (assets.sprites.Dwarf:getHeight)))
  (local json (require :lib.json))
  (local animations
         (let [data (json.decode (love.filesystem.read "assets/data/Dwarf.json"))]
           (. data :meta :frameTags)))
  (tset player :animations {})
  (each [_ animation (ipairs animations)]
    (local rate (match animation.name
                  :Trudge-DOWN 0.2
                  :Trudge-UP 0.2
                  :Idle-DOWN 0.6
                  :DOWN 0.4
                  :UP 0.4
                  :Smash 0.3))
    (tset player.animations animation.name (anim8.newAnimation (g (.. (+ animation.from 1) "-" (+ animation.to 1)) 1) rate))
    )
  (tset player :animation :Idle-DOWN)
  (tset player :image assets.sprites.Dwarf)
  )


(fn set-animation-state [player]
  (let [{: moving : holding : animation : animations} player
        next-animation (match [(not (= false moving)) (not (= false holding))]
                 [true true]   "Trudge-UP"
                 [true false]  "Trudge-DOWN"
                 [false true]  "Up"
                 [false false] "Idle-DOWN"
                 )
        active (. animations animation)]
    (pp [animation next-animation])
    (when (~= animation next-animation)
      (tset active :position 1)
      (tset active :timer 0)
      (tset player :animation next-animation)
      )
    )
  )

(fn player.update [player dt]
  (local movement (require :lib.movement))
  (local world (. (require :state) :colliders :world))
  (local (x y d m) (movement.topdown dt player.keys player))
  (local (ax ay) (world:move player (+ x player.off.x) (+ y player.off.y)))
  ;; (when (~= ax x) (tset player.speed x 0))
  ;; (when (~= ay y) (tset player.speed y 0))
  (when (not m) (tset player.speed x 0) (tset player.speed y 0))
  (set player.pos.x (- ax player.off.x))
  (set player.pos.y (- ay player.off.y))
  (local animation (. player.animations player.animation))
  (tset player :moving m)
  (tset player :holding false)
  (if (= d :left)
      (tset animation :flippedH false)
      (= d :right)
      (tset animation :flippedH true)
      )
  (set-animation-state player)
  (animation:update dt)
  )

(fn player.draw [player]
  (local animation (. player.animations player.animation))
  ;; (love.graphics.draw player.image player.pos.x player.pos.y)
  (animation.draw animation player.image player.pos.x player.pos.y)
  ;; (love.graphics.rectangle "fill" player.pos.x player.pos.y player.size.w player.size.h)
  )

(local player-mt {:__index player})

(fn create [x y]
  (local params (require :params))
  (local ret {:pos {:x (or x 192) :y (or y 172)}
              :size {:w 8 :h 8}
              :off {:x 4 :y 8}
              :type :col
              :name :player
              :pivot {:x 8 :h 16}
              :speed params.player-speed.walk
              :keys params.keys
              :moving false
              :holding false
              }
         )
  (tset ret.speed :x 0)
  (tset ret.speed :y 0)
  (load-animations ret)
  (setmetatable ret player-mt))
