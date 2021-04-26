(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We are warping past a pirate haven. Fingers crossed we don't get jumped, fleshbag.

Pirates are a superstitious bunch. They are terrified of Capacitors, and Ship Elements that depend on them."}


  :notification
  {
   :title "SS Slippery Approaches"
   :image [:Laser :Capacitor]
   :description "It's the ship of the dreaded space pirate Slippery Fingers.

Known throughout the quadrant for his horrific treatment of both biological and artificial life. Fortunately for his victims he is part of the Anti-Capacitor League, which objects to all things capacitive on space craft. You know what that means, no Lasers or Shields for this guy!

His ship, the SS Slippery, is a Sloop Class in serious disrepair. It 2 hard-points and a jump range of 0.01 quadrants.

Our Railgun will bounce off his Ceramic Armour, I recommend you build a Laser and a Capacitor. Remember, it's us or them fleshbag.

Place the Laser and Capacitor on the Red Table when you have finished it. This will mount the Laser on one of Endeavour's three hard-points.

Note the Capacitor is an auxilary Ship Element. It does not require a hardpoint.

Note, only the three leftmost primary Ship Elements will be mounted on hardpoints.

You can find the recipes to build the Laser and Capacitor to the right."
   }

   :ready
   {
    :title "SS Slippery Approaches"
    ;; :image style
    :description "Looks like you've equipped the Laser and Capacitor.

When you are ready we will smite this slippery pirate."
    :buttons [{:text "We Could Just Jump Away!" :callback :got-it}]
    }

   :battle
   {:title "Battle Pirate"
    :description ""
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "What happened to the Ceramic Armour!?

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Mater Acquired"
    :description (.. "That Laser did the trick! That Slippery pirate's ship slipped right down my throat.

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Poor Slippery Fingers :(" :callback :got-it}]
    }}
  )

(tset encounter :states
      {:notification {:requirements {:active [:laser] :export [:capacitor]}}
       :ready {:note :ready-pirate-2 :requirements {:click :got-it}}
})

encounter
