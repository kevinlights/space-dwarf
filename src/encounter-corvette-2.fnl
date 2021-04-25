(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
This sector appears to be humming with activity.

Lets hope that news of our consumption has not preceded us. We may run into some well equipped capital ships

We should probably work on replacing broken PRIMARY Ship Systems and backup AUXILIARY Ship Systems. We don't want to run out of Missiles or Capacitors."}


  :notification
  {
   :title "A Slippery Corvette Appeared"
   ;; :image style
   :description "What is the dreaded space pirate Slippery Fingers doing at the helm of an Empire Capital Ship!?

No matter, fleshbag, prepare my dinner!"
   :buttons [{:text "Don't make me do this!" :callback :got-it}]
   }

   :battle
   {:title "Fixing Past Mistakes"
    :description ""
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "The slippery meatbag has bested us!

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Matter Acquired"
    :description (.. "Time to feed on some Slippery Fish Fingers!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
   :buttons [{:text "Must You?" :callback :got-it}]
    }}
  )

(tset encounter :states {})

encounter
