(local slot {})

(fn db [text])

(fn draw-complete [self x y clean?]
  (when (not clean?)
    (love.graphics.setColor params.colours.red)
    (love.graphics.rectangle :fill (+ (or x self.pos.x) 4) (+ (or y self.pos.y) 8) 10 8 2)
    (love.graphics.setColor params.colours.dark-blue)
    (let [ratio (/ self.wear 10)]
      (love.graphics.rectangle :fill (+ (or x self.pos.x) 4) (+ (or y  self.pos.y) 8 (* 8 (- 1 ratio)))  10 (* ratio 8) 2))
    (love.graphics.setColor 1 1 1 1)
    )
  (self.container:draw (or x self.pos.x) (or y self.pos.y)))

(fn slot.draw [self x y clean?]
  (match self.filled-with
    false nil
    :CO (self.container:draw (or x self.pos.x) (or y self.pos.y))
    :FI (draw-complete self x y clean?)
    _ (love.graphics.draw self.image self.quad (or x self.pos.x) (or y self.pos.y)))
  )
(local s2c {:HF1 :filled-form
      :HF2 :filled-form
      :HF3 :filled-form
      :HF4 :filled-form
      :HF5 :filled-form
      :F1 :form
      :F2 :form
      :F3 :form
      :F4 :form
      :F5 :form
      :HS1 :hot-shape
      :HS2 :hot-shape
      :HS3 :hot-shape
      :HS4 :hot-shape
      :HS5 :hot-shape
      :ES1 :etched-shape
      :ES2 :etched-shape
      :ES3 :etched-shape
      :ES4 :etched-shape
      :ES5 :etched-shape
      :TS1 :tempered-shape
      :TS2 :tempered-shape
      :TS3 :tempered-shape
      :TS4 :tempered-shape
      :TS5 :tempered-shape
      :LU :logical-unit
      :EX :explosive
      :MA :matter
      :HM :hot-matter
      ;; :LA :laser
      ;; :PD :point-defense
      ;; :ML :missile-launcher
      ;; :CP :capacitor
      ;; :MO :mass-ordinance
      ;; :MS :missile
      ;; :SH :shield
      ;; :CA :ceramic-armour
      :FI :finished
      :CO :container
            })

(local c2s (lume.invert s2c))

(fn slice-to-category [slice]
  (. s2c slice))

(fn category-to-slice [category]
  (. c2s category))

(fn to-heated [category]
  (match category
    :matter :hot-matter
    _ category))

(fn to-cooled [category]
  (match category
    :hot-matter :matter
    _ category))

(fn to-filled [category filled-with]
  (match category
    :form (.. "H" filled-with)
    _ filled-with))

(fn to-empty [category filled-with]
  (match category
    :filled-form (filled-with:gsub "H" "")
    _ filled-with))

(fn to-heated-shape [category filled-with]
  (match category
    :filled-form (filled-with:gsub "HF" "HS")
    _ filled-with))

(fn to-tempered [category filled-with]
  (match category
    :hot-shape (filled-with:gsub "HS" "TS")
    _ filled-with))

(fn to-etched [category filled-with]
  (match category
    :hot-shape (filled-with:gsub "HS" "ES")
    :hot-matter (filled-with:gsub "HM" "EX")
    :matter (filled-with:gsub "MA" "LU")
    _ filled-with))

(local slot-mt {:__index slot})

(fn transfer-values [slot-a slot-b]
  (slot-a.clickable:transfer slot-b.clickable)
  (tset slot-b :category slot-a.category)
  (tset slot-b :filled-with slot-a.filled-with)
  (tset slot-b :quad slot-a.quad)
  (tset slot-b :temperature slot-a.temperature)
  (tset slot-b :container slot-a.container)
  (tset slot-b :wear slot-a.wear))

(fn erase-values [slot]
  (tset slot :category false)
  (tset slot :filled-with false)
  (tset slot :quad nil)
  (tset slot :temperature 0)
  (tset slot :container false)
  (tset slot :wear 10)
  (slot.clickable:erase)
  )

(fn slot.pickup [self target]
  (transfer-values self target)
  (erase-values self)
  )

(fn slot.try-mix [self target]
  (db ["interact" self.category self.parent target.category])
  (match [self.category self.parent target.category]
    [:form :anvil :hot-matter] (do
                                 (self:set (to-filled self.category self.filled-with))
                                 (set self.temperature target.temperature)
                                 (erase-values target)
                                 (love.event.push :fill-form self.filled-with self.category))
    [:filled-form :anvil false] (do
                                  (target:set (to-heated-shape self.category self.filled-with))
                                  (set target.temperature self.temperature)
                                  (self:set (to-empty self.category self.filled-with))
                                  (set self.temperature 0)
                                  (love.event.push :pickup target.filled-with target.category)
                                  )
    (where [a _ b] (or (= a :etched-shape) (= a :tempered-shape))
           (or (= b :etched-shape) (= b :tempered-shape) (= b :logical-unit) (= b :explosive)))
    (do
      (local prefab-container (require :prefab-container))
      (tset self :container (prefab-container self.atlas self.filled-with))
      (set self.filled-with :CO)
      (set self.category :container)
      (let [(success build) (self.container:add target.filled-with)]
        (when success
          (erase-values target))
        (when build
          (set self.build build)
          (set self.filled-with :FI)
          (tset self :wear 10)
          (set self.category :finished))
        (love.event.push :combine self.filled-with
                         (when (and self.container self.container.quads)
                           (lume.map self.container.quads
                                     (fn [x] (. x 3)))) build))
      )
    (where [:container _ b]  (or (= b :etched-shape) (= b :tempered-shape) (= b :logical-unit) (= b :explosive)))
    (do
      (let [(success build) (self.container:add target.filled-with)]
        (when success
          (erase-values target))
        (when build
          (set self.build build)
          (set self.filled-with :FI)
          (tset self :wear 10)
          (set self.category :finished))
        (love.event.push :combine self.filled-with
                         (when (and self.container self.container.quads)
                           (lume.map self.container.quads
                                     (fn [x] (. x 3))))
                         build))
      )
    [false _ _] (do
                  (transfer-values target self)
                  (erase-values target)
                  (love.event.push :putdown self.filled-with self.category))
    [_ _ false] (do
                  (self:pickup target)
                  (love.event.push :pickup target.filled-with target.category))
    )
  )

(fn slot.heat [self dt rate]
  (when self.filled-with
      (tset self :temperature (lume.clamp (+ self.temperature (* rate dt)) 0 1000)))
  (let [category self.category
        new-category ((if (> self.temperature 500) to-heated  (< self.temperature 200) to-cooled (fn [category] category)) category)]
    (when (~= new-category category)
      (slot.set self (category-to-slice new-category)))))

(fn slot.update [self dt args]
  (let [{: pos : offset : rate} (or args {})]
    (when (and args pos offset)
      (tset self.pos :x (+ pos.x offset.x))
      (tset self.pos :y (+ pos.y offset.y))
      (self.clickable:update dt self)
      )
    (when self.filled-with
      (self.clickable:activate self.filled-with))
    (when self.container
      (self.clickable:activate (self.container:name))
      )

    (self:heat dt (or rate -30))
    )
  )

(fn slot.quench [self]
  (let [filled-with self.filled-with
        category self.category
        new-filled-with (to-tempered category filled-with)]
    (when (~= filled-with new-filled-with)
      (self:set new-filled-with))))

(fn slot.etch [self]
  (let [filled-with self.filled-with
        category self.category
        new-filled-with (to-etched category filled-with)]
    (when (~= filled-with new-filled-with)
      (self:set new-filled-with))))

(fn slot.set [self filled-with]
  (tset self :category (if filled-with (slice-to-category filled-with) false))
  (tset self :filled-with filled-with)
  (tset self :quad (. self.atlas :quads "Blocks.aseprite" filled-with))
  (self.clickable:activate filled-with)
  ;; (self.clickable:activate filled-with)
  )

(fn slot.make [self build]
  (let [prefab-container (require :prefab-container)
        container (prefab-container self.atlas :ES1)]
    (tset self :container (container:make build))
    (tset self :filled-with :FI)
    (tset self :category :finished)
    (self.clickable:activate build)
    ))

(fn slot.erase [self]
  (self.clickable:remove)
  (erase-values self))

(fn slot.delete [self]
  (if self.container
      (do (love.event.push :mater-change (# self.container.quads))
          (self:erase))
      (or (= :hot-shape self.category)
          (= :tempered-shape self.category)
          (= :etched-shape self.category)
          (= :logical-unit self.category)
          (= :explosive self.category))
      (do (love.event.push :mater-change 1)
          (self:erase))
    ))

(fn slot.complete? [self options]
  (when (and (= :finished self.category) (. options self.container.build))
        self))

(fn create [filled-with atlas parent index x y colliders]
  (local state (require :state))
  (let [quad (. atlas :quads "Blocks.aseprite" filled-with)
        ret {:atlas atlas
             :pos {: x : y}
             :size {:w 8 :h 8}
             :off {:x 4 :y 8}
             :parent parent
             :container false
             :index index
             :type :slot
             :temperature 0
             :category (if filled-with (slice-to-category filled-with) false)
             :filled-with filled-with
             :quad quad
             :wear 10
             : colliders
             :order 1
             :image atlas.image}]
    (table.insert state.slots ret)
    (tset ret :clickable ((require :prefab-clickable) nil (+ x 0) (+ y 0) ret))
    ;; need to be deactivated by default
    ;; only activate when filled
    (ret.clickable:deactivate)
    (when filled-with
      (ret.clickable:activate filled-with))
    (colliders:add ret)
    (setmetatable ret slot-mt)
    ret))
