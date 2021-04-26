(local state (require :state))

(fn db [text])

(fn love.handlers.mater-change [value]
  (let [mater-meter (. state :objects :mater-meter)
        materializer (. state :objects :materializer)]
    (mater-meter:change value)
    (tset materializer :available-mater mater-meter.value)
    ))

(fn love.handlers.hover [element map]
  ;; (db [element map])
  )

(fn love.handlers.game-over [reason]
  (tset state :game-over true)
  (state.bgm:setVolume 0)
  ;; (state.fire:setVolume 0)
  (state.fire:stop)
  (state.birds:play)
  )


(fn love.handlers.warp []
  (assets.sounds.fire-light:play))

(fn love.handlers.arrive []
  (assets.sounds.page:play))

(fn love.handlers.resolved [status]
  (db ["battle over, success: " status])
  (state.objects.node:next)
  )


(fn love.handlers.click [element map]
  (db [:click element])
  ;; (assets.sounds.bounce:play)
  (do state.page)

  (match element
    :start-game (do
                  (state.objects.node:set :asteroid-1)
                  (state.page:play)
                  ;; (state.objects.node:set :cruiser-2 8)
                  )
    :got-it (do (state.objects.node:next)
                (tset state :init false)
                (state.page:play)
                )
    :halt-machine (love.event.push :game-over :halt-machine)
    :previous (state.objects.console:previous)
    :next (state.objects.console:next)
    :close (state.objects.console:close)
    :credits (state.objects.console:open :credits)
    :controls (state.objects.console:open :controls)
    :Armour (state.objects.console:open :ceramic-armour)
    :Ordinance (state.objects.console:open :mass-ordinance)
    :Laser (state.objects.console:open :laser)
    :Capacitor (state.objects.console:open :capacitor)
    :Shield (state.objects.console:open :shield)
    :Railgun (state.objects.console:open :point-defense)
    :Missile-Launcher (state.objects.console:open :missile-launcher)
    :Missile (state.objects.console:open :missile)
    ))

(fn love.handlers.hit [by]
  (db ["hit" by])
  (tset state :hit-timer 0.5)
  (when (not (= by :no-sound))
  (assets.sounds.fire-light:play))
  )

(fn love.handlers.combine [filled-with components build]
  (assets.sounds.cash:play)
  (db [:combine filled-with components build]))

(fn love.handlers.pickup [filled-with category]
  (assets.sounds.bounce:play)
  (db ["pickup" filled-with category]))

(fn love.handlers.putdown [filled-with category]
  (when filled-with
    (assets.sounds.bounce:play))
  (db [:putdown filled-with category]))

(fn love.handlers.fill-form [filled-with category]
  (assets.sounds.fire-light:play)
  (db ["fill-form" filled-with category]))
