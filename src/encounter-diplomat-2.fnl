(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We seem to be trapped in some sort of tractor vortex...

It couldn't be? Is it those blasted diplomatic meatbags pulling a fast one on us?"}


  :notification
  {
   :title "An Enterprising Ship Reappears"
   ;; :image style
   :description "Fleshbag, look! Those sneaky diplomats have mounted Missile-Launchers on their third hard point.

I recommend you build more Missiles and ensure that we always have ceramic armour on while their Missile-Launchers are active.

There will be no more hand holding fleshbag. I have a feeling we will face much strife before we arrive at the Alpha Z quadrant.

The recipes can be found on to the right."
   :buttons [{:text "Why do you make me do this?" :callback :got-it}]
   }

   :battle
   {:title "Reheat Leftovers"
    :description ""
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "The blasted meatbags have bested us!

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Matter Acquired"
    :description (.. "Now that's what I call a Double Dipping of Diplomacy!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
   :buttons [{:text "Picaaard!!!" :callback :got-it}]
    }}
  )

(tset encounter :states {})

encounter
