(local encounter {})

(fn encounter.notes [loadout aux mater style]
  {
   :warp
   {:title "Warping"
   :description "
So close, I can almost smell Alpha Z, meats.

Soon I will feed, feed on all existence.

Nothing now stands between me and my objective!"}

  :notification
  {
   :title "Cruiser Cruising In"
   ;; :image style
   :description "We've been had, fleshbag!

That is a fully equipped Imperial Cruiser!

Before we engage we must replace any broken PRIMARY Ship Systems and backup AUXILIARY Ship Systems. We don't want to run out of Missiles or Capacitors.

I'd also recommend we build a few backup Ceramic Armours"
   :buttons [{:text "Make Me" :callback :got-it}]
   }

   :battle
   {:title "The Final Step"
    :description ""
    }

   :failure
   {
    :title "Ship Condition Critical"
    :description (.. "You disappoint us, fleshbag.

We have managed to pick up " mater " mater when passing through the debris field.

The ship's condition is critical. Warping out of this sector immediately!")
    :buttons [{:text "Why won't this ship go down!?" :callback :got-it}]
    }

  :success
  {
   :title "Mater Acquired"
    :description (.. "Time to end existence, fleshbag

Prepare to destroy this sector, and all other sectors")
   :buttons [{:text "I Won't Let You!" :callback :halt-machine}]
    }}
  )

(tset encounter :states {})

encounter
