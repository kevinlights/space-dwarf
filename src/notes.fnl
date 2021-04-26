(local
 notes
 {:Dwarf {:title "Space Dwarf"
          :description "Sometimes labour is cheaper than automation. Especially when you're talking about Dwarf labour.

You are the only biological life-form on the SS Endeavour, which has been floating through space for nigh 200 years."
          :image [:Dwarf]
          :buttons []
          }

  :intro {:title "Space Dwarf"
          :description "

"
          :buttons [{:text "Start" :callback :start-game}
                    {:text "Credits" :callback :credits}
                    {:text "Controls" :callback :controls}]
          }

  :controls {:title "Controls"
             :description "
  - Move with WSAD.
  - Pickup and put down items with SPACE.
  - Delete item in your hands with DELETE.
  - You can click on any element on screen for details."
             :buttons []}
  :credits {:title "Credits"
            :description"
Font (FFForwa) - (OFL)
Font (Inconsolata) - (OFL)
Sounds Effects -  NeadSimic, Nicole Marie, Jalastram, Blender Foundation, MentalSanityOff (CCBY 3/4)
Library (Lume) - RXI (MIT/X11)
Library (anim8,bump) - Enrique Cota (MIT)
Engine (LÖVE) - LÖVE Dev Team (Zlib)
Language (Fennel) - Calvin Rose (MIT/X11)
Web Support (Love.js) Davidobot"
            :buttons []}
  :FU {:title "Furnace"
       :image :FU
       :description"Working the Furnace is an ancient Dwarven right. Or at least that's what the AI says.

Place mater by the furnace to heat it up!"
       :buttons []}

  :MT {:title "Materializer"
       :image :MT
       :description "Nothing is more essential to modern space travel. The Materializer breaks dilithum into a sub atomic state and produces a generic mater, space style.

Every dwarf knows that producing mater is the first step in any crafting exercise."
       :buttons []}

  :AN {:title "Anvil"
       :image :AN
       :description "Cold, even for space. The anvil provides the structural rigidity needed for shape formation.

Place the form for any shape you wish to produce on the anvil and then pour in hot mater."
       :buttons []}

  :quencher {:title "Quencher"
             :image :QU
             :description "Place Hot Shapes into the Quencher to convert them to the structurally sound Tempered Shapes"
             :buttons []}

  :etcher {:title "Nanite Etcher"
           :image :ET
           :description "Place Hot Shapes into the Nanite Etcher to convert them to Etched Shapes"
           :buttons []}

  :table-pre {:title "Wooden Table"
              :image :table-blue-3
              :description "A wooden table that sits next to the Furnace. You can store anything you want on this table.

Stack Tempered Shapes, Etched Shapes, Logical Units or Explosives on tables to produce equipment needed for the ships functions."
              :buttons []}

  :table-shape {:title "Wooden Table"
                :image :table-blue-4
                :description "A wooden table that holds Shape Forms. While this table was meant to hold Shape Forms, you can store anything you want on this table.

Stack Tempered Shapes, Etched Shapes, Logical Units or Explosives on tables to produce equipment needed for the ships functions."
                :buttons []}

  :table-work {:title "Small Wooden Table"
               :image :table-blue-1
               :description "A small table. You can store anything you want on this table.

Stack Tempered Shapes, Etched Shapes, Logical Units or Explosives on tables to produce equipment needed for the ships functions."
               :buttons []}

  :table-hold {:title "Long Wooden Table"
               :image :table-blue-long
               :description "A long table. This table is the recommended location to store completed items that are not active.

Stack Tempered Shapes, Etched Shapes, Logical Units or Explosives on tables to produce equipment needed for the ships functions."
               :buttons []}

  :table-export {:title "Active Table"
                 :image :table-red-long
                 :description "This table is different than the others. It's red.

All jokes aside, items put on this table are directly connected to the ships functions.

Lasers, Rail Guns, Missile Launchers, Shields and Ceramic Armour will be mounted into one of the three available hard-points, with a preference for items to the left.

Capacitors, Rail Gun Ammo and Missiles also need to be stored on this table to be accessed by the active ship systems."
                 :buttons []}

  :player-ship {:title "The SS Endeavour"
                :image :Ship-Host
                :description "An AI ship, making the long haul from the Alpha Y quadrant to  the Alpha Z quadrant for reasons that only AI understand.

It is a Lesser Diplomat Class in moderate disrepair with 3 hard-points and a jump range of 0.05 quadrants.

One sentient lifeform is detected. It safe to assume this is a detection error."
                :buttons []}
  :MA {:title "Mater"
       :image :MA
       :description "Mater, a useful assortment of sub atomic particles.

Ideally used in conjunction with a replicator, but cheaper options are available."
       :buttons []}

  :HM {:title "Heated Mater"
       :image [:FU :plus :MA :equals "HM"]
       :description "Mater, of the heated variety.

This form of Mater flows nicely into Shape Forms."
       :buttons []}

  ;; SHIPS
  :boss {:title "SS Destruction"
         :image "Cruiser"
         :description ""
         :buttons []
         }

  ;; Finished Goods
  :laser {:title :Laser
          :image [:TS3 :plus :LU :plus :ES5 :plus :ES2 :equals :Laser]
          :description "Pew Pew, the ultimate expression of space dominance.

Lasers ignore point-defense Railguns and Ceramic Armour. The only defense against them are Shields. A Shield can take three hits from a Laser before it fails.

Requirements: Lasers require Capacitors to function. A Laser will fully drain a capacitor after 5 shots.

Effect: A Laser, if not stopped by Sheilds, will completely destroy one Ship Element mounted on a hard-point."
          :buttons []}

  :point-defense {:title "Rail Gun"
                  :image [:ES2 :plus :LU :plus :TS5 :plus :TS3 :equals :Railgun]
                  :description "Awe inspiring kinetic energy in the steel.

Railguns are the only Ship Component that has both an offensive and defensive function.

Offensively, Railguns ignore shields and other point-defense Railguns. The only defense against Railguns is Ceramic Armour. Ceramic Armour can take 10 hits from a Railgun before it fails.

Defensively, Railguns function as Point Defense, shooting down approaching Missiles. They have a 70% chance of intercepting approaching Missiles.

Railguns are also very effective at deflecting approaching Asteroids.

Requirements: Railguns consume Mass-Ordinance with every shot. A Railgun will fully drain a Mass-Ordinance after 10 shots.

Effect: A Railgun, if not stopped by Ceramic Armour, will completely destroy one Ship Element mounted on a hard-point."
                  :buttons []}

  :missile-launcher {:title "Missile Launcher"
                     :image [:ES2 :plus :LU :plus :TS5 :plus :TS3 :equals :Missile-Launcher]
                     :description "In space, no one can hear your ship exploding.

Missiles are the most deadly offensive weapons. A single hit from a Missile can render a ship space-scuttled. Missiles are not effected by Shields, but can be intercepted by Railguns and stopped by Ceramic Armour.

A Railgun has a 70% chance of intercepting a missile. Ceramic Armour can also protect a ship from missiles. Ceramic Armour will be completely destroyed after a single hit.

Requirements: Missile Launchers, as expected, consume Missiles. A Missile Launcher will fully drain a Missile store after two shots.

Effect: A Missile Launcher, if not stopped by a Railgun or Ceramic Armour, will destroy all ship elements mounted on hard-points.
"
                     :buttons []}

  :ceramic-armour {:title "Ceramic Armour"
                   :image [:TS3 :plus :TS4 :equals :Armour]
                   :description "I'll give you one guess about what keeps you from the howling emptiness of space.

Ceramic Armour protects your ship from Missile Launchers and Railguns. It is also an effective defense against asteroids.

Ceramic Armour can take 10 hits from a Rail Gun and one hit from a Missile Launcher. Note even if the Ceramic Armour has been hit by a Rail Gun 9 times it can still capture the full blast of a Missile Launcher. Asteroids will bounce right off Ceramic Armour.
"
                   :buttons []
                   }

  :shield {:title "Shields"
           :image [:TS2 :plus :LU :plus :ES5 :equals :Shield]
           :description "While they look like the Northern Lights, these bad girls are critical to keeping you safe.

Shields protect your ships safe from lasers. Shields can take 3 hits from a Laser before they fail.

Requirements: Shields require Capacitors to function. A Shield will drain a capacitor after 5 hits.
"
           :buttons []}

  :capacitor {:title "Capacitors"
              :image [:ES2 :plus :LU :plus :ES1 :Capacitor]
              :description "Shockingly useful, these little devices provide the acutely high power requirements of both Lasers and Shields.

Without Capacitors Lasers and Shields will not function. Lasers and Shields can share one or more Capacitors.

A Capacitor will be drained after 5 cumulative uses by either a Shield or a Laser."
              :buttons []}

  :mass-ordinance {:title "Mass Ordinance"
                   :image [:TS4 :plus :TS4 :equals :Ordinance]
                   :description "These are just hunks of tempered metal.

Mass-Ordinance are used by Railguns in both defensive and offensive actions. Without Mass-Ordinance Railguns will not function.

A Mass-Ordinance store will be drained after 10 uses by a Railgun."
                   :buttons []}

  :missile {:title "Missile"
            :image :Missile
            :description "Dying to rain destruction down upon your enemies? Try a Missile today.

Missiles are use by Missile Launchers. Without a Missile, Missile Launchers will not functions.

A Missile store will be drained after two uses by a Missile Launcher."
            :buttons []}

  :LU {:title "Logical Unit"
       :image [:ET :plus :MA :equals :LU]
       :description "The core of almost all Ship Elements."
       :buttons []}

  :EX {:title "Explosive"
       :image [:ET :plus :HM :equals :EX]
       :description "Unstable heated mater that forms the core of Missiles."
       :buttons []}

  :CO {:title "Work in Progress"
       :description "A partially complete ship element. Press DELETE when holding to recapture the mater."
       :buttons []}
  })


(fn change-shape-to [shape prepend]
  (.. prepend (shape:sub 3 4)))

(fn heat [shape]
  (change-shape-to shape :HS))

(fn hot-form [shape]
  (change-shape-to shape :HF))

(fn form [shape]
  (change-shape-to shape :F))

(fn tempered-shape-image [repeatable]
  [:QU :plus (heat repeatable) :equals repeatable])

(fn etched-shape-image [repeatable]
  [:ET :plus (heat repeatable) :equals repeatable])

(fn heated-shape-image [repeatable]
  [:AN :plus (form repeatable) :plus :HM :equals repeatable])

(fn make-repeatable [count repeatable title images description]
  {
   :title title
   :image (images (.. repeatable count))
   :description description
   :buttons []
   }
  )

(for [i 1 5]
  (tset notes (.. :TS i)
        (make-repeatable i :TS "Tempered Shape" tempered-shape-image
                         "A very strong structural unit. Used in the production of ship components."))
  (tset notes (.. :ES i)
        (make-repeatable i :ES "Etched Shape" etched-shape-image
                         "A very detailed structural unit. Used in the production of ship components."))
  (tset notes (.. :HS i)
        (make-repeatable i :HS "Heated Shape" heated-shape-image
                         "Heated Mater formed into a useful shape."))
  (tset notes (.. :F i) (make-repeatable i :F "Form" (fn [x] [x])
                                         "Place this form on an anvil and fill with Heated Mater to produce a Heated Shape."))
  (tset notes (.. :HF i) (make-repeatable i :HF "Filled Form" (fn [x] [x])
                                          "This form is filled with Heated Mater."))
  )

(fn [key value]
  (if value
      (tset notes key value)
      (if (= :string (type key))
          (. notes key)
          (let [ret (. notes :CO)]
            (tset ret :image key)
            ret))))
