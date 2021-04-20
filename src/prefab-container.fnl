(local container {})

(fn container.draw [self x y]
  (each [_ [quad y-offset _] (ipairs self.quads)]
    (love.graphics.draw self.image quad x (- y y-offset))))

(fn slice-check [slice]
  (or (string.match slice "^[ET]S[1-5]")
      (string.match slice "^LU$")
      (string.match slice "^EX$")))

(fn slice-breakout [slice]
  (match (slice:sub 1 2)
    :ES (values :ES (string.match slice "[1-5]"))
    :TS (values :TS (string.match slice "[1-5]"))
    :LU (values :LU :4)
    :EX (values :EX :4)))

(local y-offsets
       {:0 {:1 3 :2 3 :3 4 :4 3 :5 2}
        :1 {:1 3 :2 3 :3 3 :4 3 :5 3}
        :2 {:1 3 :2 3 :3 1 :4 1 :5 3}
        :3 {:1 3 :2 4 :3 4 :4 1 :5 4}
        :4 {:1 2 :2 2 :3 2 :4 3 :5 2}
        :5 {:1 2 :2 2 :3 2 :4 2 :5 2}
        }
       )

(local builds {:capacitor [:ES2 :LU :ES1]
               :ceramic-armour [:TS3 :TS4]
               :missile-launcher [:ES2 :LU :TS5 :TS2]
               :point-defense [:ES2 :LU :TS5 :TS3]
               :laser [:TS3 :LU :ES5 :ES1]
               :sheild [:TS2 :LU :TS5]
               :missile [:TS3 :EX :TS1]
               :mass-ordinance [:TS4 :TS4]})

(local flat-builds (lume.map builds lume.serialize))

(fn check-build [quads]
  (let [current-build (lume.serialize (lume.map quads (fn [[_ _ slice]] slice)))
        keys (lume.keys (lume.filter flat-builds (fn [build] (= current-build build)) true))]
    (when keys
      (. keys 1))
    ))

(fn get-y-offset [quads filled-with]
  (var offset 0)
  (each [_ [_ off slice ] (ipairs quads)]
    (pp [slice off (. y-offsets :2) [(slice-breakout slice)]])
    (let [(_ parent-slice-number) (slice-breakout slice)
          (_ slice-number) (slice-breakout filled-with)
          new-off (+ off (. y-offsets parent-slice-number slice-number))]
      (when (> new-off offset)
        (set offset new-off)
        )))
  offset)

(fn container.add [self filled-with]
  (assert (~= nil (slice-check filled-with)))
  (when (< (# self.quads) 6)
    (let [quad (. self.atlas :quads "Blocks.aseprite" filled-with)
          y-offset (get-y-offset self.quads filled-with)
          ]
      (table.insert self.quads [quad y-offset filled-with])
      (set self.build (check-build self.quads)))
    (pp self)
      (values true self.build)))

(local container-mt {:__index container})

(fn container.make [self build]
  (assert (. builds build))
  (let [order (. builds build)
        filled-with (. order 1)
        quad (. self.atlas :quads "Blocks.aseprite" filled-with)]
    (tset self :quads [[quad 0 filled-with]])
    (for [i 2 (# order)]
      (let [filled-with (. order i)]
        (self:add filled-with)))
    (tset self :build build)
    )
  self
  )

(fn create [atlas filled-with]
  (assert (~= nil (slice-check filled-with)))
  (let [quad (. atlas :quads "Blocks.aseprite" filled-with)
        ret {:atlas atlas
             :quads [[quad 0 filled-with]]
             :build nil
             :image atlas.image}]
    (setmetatable ret container-mt)
    ret))
