(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We are warping through the deep void. We do not expect to encounter sentient life."}


  :notification
  {
   :title "Asteroid Field"
   :image [:Armour]
   :description "Again!?

Just our luck. We have jumped straight into ANOTHER Asteroid Field!

I recommend you build Ceramic Armour to protect the ship.

Place the Ceramic Armour on the Red Table when you have finished it. This will mount the armour on one of Endeavour's three hard-points.

Press the button below to see how to assemble Ceramic Armour. You can also click on its icon to the right."
   }

   :ready
   {
    :title "Asteroid Field"
    ;; :image :Asteroid
    :description "Looks like you've equipped the Ceramic Armour.

When you are ready we will proceed through the Asteroid Field."
    :buttons [{:text :Ready! :callback :got-it}]
    }

   :battle
   {:title "Passing Through"
    :description ""
    }

   :failure
   {
    :title "Ship Condition Critical"
    :image :Asteroid
    :description (.. "What happened to the Ceramic Armour!?

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Cleared the Asteroid Field"
    :image :Asteroid
    :description (.. "That Ceramic Armour did the trick!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }}

  )

(tset encounter :states
      {:notification {:requirements {:active [:ceramic-armour]}}
       :ready {:note :ready-asteroid-2 :requirements {:click :got-it}}
})

encounter
