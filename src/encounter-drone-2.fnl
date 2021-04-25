(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We are warping past a dead solar system. It looks like our Machine Brothers long ago cleansed this sector.

Machines have a superiority complex. Hard to believe I know. They refuse to use any \"old\" technology, such as Missile-Launchers, Ceramic Armour and Railguns.

We should probably build some Shields just in case we come across some of their Drones."}


  :notification
  {
   :title "Oh No! A Deafening Drone"
   :image [:Shield :Railgun :Capacitor]
   :description "Oh how tasty, it looks like one of our brothers has floated into our webs.

This fool places too much confidence in his Lasers and Shields. Little do they know we have a breathing meat bag aboard this ship, who can comprehend physical armaments.

For defense, I recommend you build a Shield and another Capacitor.

Place the new Shield on the Red Table when you have finished it. This will mount the Laser on one of Endeavour's three hard-points.

For offense, I recommend you also equip the Railgun and Mass-Ordinance.

Remember, only the three leftmost primary Ship Elements will be mounted on hardpoints.

You can find the recipes to build the Shield to the right."
   }

   :battle
   {:title "Subdue Brethren"
    :description ""
    }

   :ready
   {
    :title "Oh No! A Deafening Drone"
    ;; :image style
    :description "Looks like you've equipped the Shield, Railgun and Capacitor.

When you are ready we will preform a recall upon our lost brother."
    :buttons [{:text "Recall?" :callback :got-it}]
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "Fleshbag!!! How have we been bested by this backwards bumpkin!

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Matter Acquired"
    :description (.. "Time to feed.

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Even Your Own Brethren!?" :callback :got-it}]
    }}
  )

(tset encounter :states
      {:notification {:requirements {:active [:shield :point-defense] :export [:capacitor]}}
       :ready {:note :ready-drone-2 :requirements {:click :got-it}}
})

encounter
