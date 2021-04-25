(local node {})

(var text-font (assets.fonts.inconsolata (* 6 scale)))

(fn node.draw [self]
  (when (and self.state self.text)
    (love.graphics.push "all")
    (love.graphics.scale (/ 1 scale))
    (love.graphics.setFont text-font)
    (love.graphics.setColor params.colours.red)
    (love.graphics.rectangle "fill" (* scale self.pos.x) (* scale (+ 1 self.pos.y)) (* 76 scale) (* 14 scale) (* 4 scale) 2)
    (love.graphics.setColor params.colours.blue)
    (let [ratio (lume.clamp (if (~= self.period 0) (/ self.timer self.period) 1) 0 1)]
      (love.graphics.rectangle "fill" (* scale self.pos.x) (* scale (+ 1 self.pos.y)) (* ratio 76 scale) (* 14 scale) (* 4 scale) 2))
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.printf self.text (* scale (+ 3 self.pos.x)) (* scale (+ 4 self.pos.y)) (* 70 scale) :center)
    (love.graphics.pop)))

(fn handle-requirements [self]
  (when self.requirements
    (let [requirements self.requirements
          state (require :state)
          hardpoints (. state :objects :ship :hardpoints)
          export-table (. state :objects :table-export)
          active (-> hardpoints
                     (lume.filter (fn [hardpoint] (and (= :table (type hardpoint.slot))
                                                       (= :table (type hardpoint.slot.container)))))
                     (lume.map (fn [hardpoint] hardpoint.slot.container.build))
                     (lume.invert))
          export (->  export-table.slots
                      (lume.filter (fn [slot] (and (= :table (type slot)) slot.container (= :table (type slot.container)) slot.container.build)))
                      (lume.map (fn [slot] slot.container.build))
                      (lume.filter (fn [build] build))
                      (lume.invert))
          ]
      (var next true)
      (each [key value (pairs requirements)]
        (set next (and next
                       (match key
                         :click false
                         :active (do
                                   ;; (pp {:active active :value value})
                                   (lume.all value (fn [v] (. active v))))
                         :export (lume.all value (fn [v] (. export v)))
                         :timer (do (set self.period value)
                                    ;; (pp [self.timer self.period])
                                    (> self.timer self.period))
                         )))
        )
      (when next
        (self:next))
      ))
  )

(fn node.update [self dt]
  (tset self :timer (+ self.timer dt))
  (handle-requirements self)
  )

(fn start-battle [self]
  (let [states self.states
        console (. (require :state) :objects :console)]
    (local next-state (. states :battle))
    (when (. next-state :text)
      (tset self :text (. next-state :text)))
    (tset self :period 15)
    (tset self :timer 0)
    (tset self :requirements (. next-state :requirements))
    (tset self :state :battle)
    (tset self :turn :enemy)
    (when (. next-state :note)
      (console:clear (. next-state :note)))
    )
  )

(fn goto [self state-name]
  (let [states self.states
        console (. (require :state) :objects :console)]
    (local next-state (. states state-name))
    (tset self :state state-name)
    (tset self :requirements (. next-state :requirements))
    (pp ["next-state" state-name (. next-state :note)])
    (when (. next-state :note)
      (console:clear (. next-state :note)))))

(fn goto-notification [self]
  (local enemy-ship (. (require :state) :objects :enemy-ship))
  (enemy-ship:set self.name)
  (tset self :text "Prep Period")
  (goto self :notification))

(fn goto-ready [self]
  (tset self :text "Prep Period")
  (goto self :ready))

(fn goto-battle [self]
  (tset self :text "Battle")
  (start-battle self))

(fn goto-failure [self]
  (tset self :text "Preparing to Warp")
  (pp (. self.states :failure))
  (let [mater (. self.states :failure :mater)]
    (when mater
      (love.event.push :mater-change mater)))
  (goto self :failure))

(fn goto-success [self]
  (tset self :text "Preparing to Warp")
  (pp (. self.states :success))
  (let [mater (. self.states :success :mater)]
    (when mater
      (love.event.push :mater-change mater)))
  (goto self :success))

(fn initialize-node [node name]
  (let [nodes (require :nodes)
        node-data (do ;;(pp name) (pp nodes)
                    (. nodes name))
        console (. (require :state) :objects :console)
        state (. node-data.states node-data.state)]
    (each [key value (pairs node-data)]
      (tset node key value))
    (tset node :requirements (. state :requirements))
    (console:clear (. state :note))
  ))

(fn goto-warp [self name]
  (local starfield (. (require :state) :objects :starfield))
  (local enemy-ship (. (require :state) :objects :enemy-ship))
  (tset self :text "Warping")
  (tset self :name name)
  (starfield:warp)
  (enemy-ship:set nil)
  (initialize-node self name))

(fn select-node [order]
  (. [:asteroid-2 :transport :pirate-2 :drone-2 :diplomat-1 :diplomat-2 :corvette-2 :cruiser-2] order))

(fn node.next [self]
  (let [name self.state
        states self.states
        success self.success]
    (local starfield (. (require :state) :objects :starfield))
    (pp ["Node Next -" name])
    (set self.timer 0)
    (set self.period 0)
    (match name
      :warp (do (starfield:fight) (goto-notification self))
      :notification (if (. states :ready) (goto-ready self) (goto-battle self))
      :ready (goto-battle self)
      :battle (if success (goto-success self) (goto-failure self))
      :failure (goto-warp self (select-node self.node-order))
      :success (do (tset self :node-order (+ 1 self.node-order))
                   (goto-warp self (select-node self.node-order))))
    ))

(fn node.set [self name]
  (initialize-node self name)
  (set self.timer 0))

(local node-mt {:__index node})

(fn create [_atlas x y _args]
  (setmetatable
    {:pos {: x : y} :size {:w 0 :h 0}
     :timer 0 :period 0
     :node-order 1
     :turn :enemy
     :name :asteroid-1
     :success true
     :text "" :states {} :state nil}
   node-mt)
  )
