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
                 [false true]  "UP"
                 [false false] "Idle-DOWN"
                 )
        active (. animations animation)]
    (when (~= animation next-animation)
      (tset active :position 1)
      (tset active :timer 0)
      (tset player :animation next-animation)
      )
    )
  )

(fn slot-filter [item]
   (and (= :slot item.type ) (~= :player item.parent)))

(fn closest-slot [player]
  (let [state (require :state)
        colliders (. state :colliders)
        x player.pos.x
        y player.pos.y
        (items len) (colliders.world:queryRect (- x 10 -8) (- y 10 -8) 20 20 slot-filter)]
    (var dist 10024)
    (var closest false)
    (each [_ slot (ipairs items)]
      (let [new-dist (lume.distance x y slot.pos.x slot.pos.y true)]
        (when (< new-dist dist)
          (set dist new-dist)
          (set closest slot))))
    closest))

(fn slot-interact [player]
  (let [player-slot (. player :slots 1)
        closest-slot player.closest-slot]
    (when closest-slot
       (closest-slot:try-mix player-slot)
    )))

(fn move-filter [_item other]
  (if (= :col other.type )
      :slide
      :cross))

(fn player.update [player dt]
  (local movement (require :lib.movement))
  (local world (. (require :state) :colliders :world))
  (local (x y d m) (movement.topdown dt player.keys player))
  (local (ax ay) (world:move player (+ x player.off.x) (+ y player.off.y) move-filter))
  ;; (when (~= ax x) (tset player.speed x 0))
  ;; (when (~= ay y) (tset player.speed y 0))
  (when (not m) (tset player.speed x 0) (tset player.speed y 0))
  (set player.pos.x (- ax player.off.x))
  (set player.pos.y (- ay player.off.y))
  (local animation (. player.animations player.animation))
  (tset player :moving m)
  (tset player :holding (. player :slots 1 :category))
  (if (= d :left)
      (tset animation :flippedH false)
      (= d :right)
      (tset animation :flippedH true)
      )
  (set-animation-state player)
  (animation:update dt)
  ;; Move slot
  (let [slot (. player.slots 1)
        clickable player.clickable]
    ;;(- x 2) (- y 10)
    (clickable:update dt {:pos {:x (- player.pos.x 2)
                                :y (- player.pos.y 10)}})
    (slot:update dt {:pos player.pos :offset {:x 0 :y -10}}))

  (tset player :closest-slot (closest-slot player))
  )

(fn player.draw [player]
  (local animation (. player.animations player.animation))
  ;; (love.graphics.draw player.image player.pos.x player.pos.y)
  (animation.draw animation player.image player.pos.x player.pos.y)
  (each [_ slot (ipairs player.slots)] (slot:draw))
  (when (and player.debug player.closest-slot)
    (love.graphics.setColor 1 0 0 1)
    (love.graphics.rectangle "fill" (+ 4 player.closest-slot.pos.x) (+ 8 player.closest-slot.pos.y)
                             8 8)
    (love.graphics.setColor 0 1 0 1)
    (love.graphics.rectangle "line" (- player.pos.x 10 -8) (- player.pos.y 10 -8)
                             20 20)
    (love.graphics.setColor 1 1 1 1)

    )


  ;; (love.graphics.rectangle "fill" player.pos.x player.pos.y player.size.w player.size.h)
  )

(fn slot-interact-callback [player]
  (tset player :closest-slot (closest-slot player))
  (slot-interact player))

(fn delete-slot-callback [player]
  (pp "delete")
  (: (. player.slots 1) :delete)
  )

(fn player.keypressed [player key]
  (match key
    :space (do (slot-interact-callback player) nil)
    :return (do (slot-interact-callback player) nil)
    :backspace (do (delete-slot-callback player) nil)
    :delete (do (delete-slot-callback player) nil)
    _ key)
  )

(local player-mt {:__index player})

(fn create [atlas x y  {: colliders : prefab-slot}]
  (local params (require :params))
  (local slot1 (prefab-slot false atlas :player 1 (+ x 3) (+ y 8) colliders))
  (local ret {:pos {:x (or x 192) :y (or y 172)}
              :size {:w 4 :h 4}
              :off {:x 6 :y 12}
              :type :player
              :name :player
              :slots [slot1]
              :pivot {:x 8 :h 16}
              :speed params.player-speed.walk
              :keys params.keys
              :moving false
              :holding false
              :closest-slot false
              : colliders
              :w 8
              :h 14
              }
         )
  (tset ret.speed :x 0)
  (tset ret.speed :y 0)
  (load-animations ret)
  (setmetatable ret player-mt)
  (tset ret :clickable ((require :prefab-clickable) nil (- x 2) (- y 10) ret))
  (ret.clickable:activate "Dwarf")
  (colliders:add ret))
