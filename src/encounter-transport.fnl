(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
We are warping past a fuel depot. Keep your eyes peeled for Transports.

Transports are pushovers and can easily be taken out with a Railgun."}


  :notification
  {
   :title "A Wild Transport Has Appeared"
   :image [:Railgun :Ordinance]
   :description "I know how squeamish biologics are when it comes to taking out helpless transports. That is why you listen to machines now!

I \"recommend\" you build a Railgun and Mass-Ordinance so we can take down the Transport. We could make much more effective use of its matter.

Place the Railgun and Mass-Ordinance on the Red Table when you have finished it. This will mount the Railgun on one of Endeavour's three hard-points.

Note the Mass-Ordinance is an auxiliary Ship Element. It will be consumed by the Railgun and does not require a hardpoint.

You can find the recipes to build the Railgun and Mass-Ordinance to the right."
   }

   :battle
   {:title "Engaging Transport"
    :description ""
    }

   :ready
   {
    :title "A Wild Transport Has Appeared"
    :image style
    :description "Looks like you've equipped the Railgun and Mass-Ordinance.

When you are ready we will acquire the mater from this Transport."
    :buttons [{:text "You Monster!" :callback :got-it}]
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
    :description (.. "That Railgun did the trick! Now time to feed!

We have managed to pick up " mater " mater when passing through the debris field.

Prepare to warp out of this sector.")
    :buttons [{:text "Curse You!" :callback :got-it}]
    }}

  )

(tset encounter :states
      {:notification {:requirements {:active [:point-defense] :export [:mass-ordinance]}}
       :ready {:note :ready-transport :requirements {:click :got-it}}
})

encounter
