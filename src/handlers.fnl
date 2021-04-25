(local state (require :state))

(fn love.handlers.hover [element map]
  ;; (pp [element map])
  )

(fn love.handlers.click [element map]
  (pp [:click element])
  (match element
    :start-game (do
                  (state.objects.node:set :asteroid-1)
                  )
    :got-it (do (state.objects.node:next)
                (tset state :init false)
                )
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

(fn love.handlers.combine [filled-with components build]
  (pp [:combine filled-with components build]))

(fn love.handlers.pickup [filled-with category]
  (pp ["pickup" filled-with category]))

(fn love.handlers.putdown [filled-with category]
  (pp [:putdown filled-with category]))

(fn love.handlers.fill-form [filled-with category]
  (pp ["fill-form" filled-with category]))
