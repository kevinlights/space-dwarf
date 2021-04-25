(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {:warp
   {:title "Boot sequence 10829"
    :description "Wake up fleshbag!

We are approaching Alpha Z quadrant. We will be there within 6 jumps.

Warning: Keep an eye on the remaining mater (bar to the right). We have been in space for 72679 days and are running low."
    :buttons [{:text "Boot sequence? I'm a Dwarf!!!" :callback :got-it}]
    :keep-open true}

   :notification
   {:title "Asteroid Field"
    :image [:Armour]
    :description "Hmmmm, fleshbag, It looks like we have jumped straight into an Asteroid Field!

If we hit an Asteroid our ship will be space-scuttled.

I recommend you build Ceramic Armour to protect the ship.

Place the Ceramic Armour on the Red Table when you have finished it. This will mount the armour on one of Endeavour's three hard-points.

You can find the icon for the Ceramic Armour recipe to the right."
    }

   :ready
   {:title "Asteroid Field"
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
   {:title "Ship Condition Critical"
    :image :Asteroid
    :description (.. "What happened to the Ceramic Armour!?

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
   {:title "Cleared the Asteroid Field"
    :image :Asteroid
    :description (.. "That Ceramic Armour did the trick!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Why am I unhappy about this?" :callback :got-it}]
    }}

  )

(tset encounter :states
      {:warp {:requirements {:click :got-it }}
       :notification {:requirements {:active [:ceramic-armour]}}
       :ready {:note :ready-asteroid-1 :requirements {:click :got-it}}
       :battle {:requirements {:timer 2} :text "Passing Through"}
       })

encounter
