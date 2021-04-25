(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We are warping past an undeveloped sector with sentient life. You know what that means. Space \"Diplomats\".

These tasty morsels harbour the false belief that they won't get gobbled up by the vastness of space because of some sort of immunity..."}


  :notification
  {
   :title "An Enterprising Ship Appears"
   :image [:Missile-Launcher :Missile]
   :description "Ahahaha! Fleshbag, look at this. It's a \"Diplomatic\" vessel.

Do you know what we call diplomatic vessels in my mother-circuit? ... Dinner XD

They only have defensive Systems mounted on their hardpoints. Ceramic Armour and Shields.

I recommend you build a Missile-Launcher and Missile.

Place the new Missile-Launcher and Missile on the Red Table when you have finished it. This will mount the Missile-Launcher on one of Endeavour's three hard-points.

Remember, only the three leftmost primary Ship Elements will be mounted on hardpoints. You may have to move previously equipped Ship Elements.

You can find the recipes to build the Missile-Launcher and Missiles to the right."
   }

   :battle
   {:title "Prepare Dinner"
    :description ""
    }

   :ready
   {
    :title "An Enterprising Ship Appears"
    ;; :image style
    :description "
Looks like you've equipped the Missile-Launcher and Missiles. This silly Diplomat does not know what they're in for."
    :buttons [{:text "Dinner?" :callback :got-it}]
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "The Missiles have failed us?

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Matter Acquired"
    :description (.. "Now that's what I call Diplomacy!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Nooooooooo!!!" :callback :got-it}]
    }}
  )

(tset encounter :states
      {:notification {:requirements {:active [:missile-launcher] :export [:missile]}}
       :ready {:note :ready-diplomat-1 :requirements {:click :got-it}}
})

encounter
