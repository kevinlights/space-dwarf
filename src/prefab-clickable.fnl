(local clickable {})

(fn clickable.activate [self element?]
  (when element?
    (tset self :element element?))
  (set self.type :click))

(fn clickable.deactivate [self]
  (set self.type :inactive))

(fn clickable.action [self x y]
  (match self.element
    :description (tset (require :state) :drag y)
    _ (let [console (. (require :state) :objects :console)]
      (console:open self.element))))

(fn clickable.hover [self x y map]
  (when (and self self.element (= :table (type map)) (. map self.element))
    (tset (. map self.element) :hover true)))

(fn clickable.remove [self]
  (self.colliders:remove self)
  (set self.type :inactive))

(fn clickable.erase [self]
  (set self.type :inactive)
  (set self.element nil))

(fn clickable.update [self dt obj]
  (when obj
    (set self.pos.x obj.pos.x)
    (set self.pos.y obj.pos.y))
  (self.colliders:update self))

(fn clickable.transfer [self new-owner-clickable]
  (let [new-element self.element
        new-type self.type
        ]
    (tset self :element new-owner-clickable.element)
    (tset self :type new-owner-clickable.type)
    (tset new-owner-clickable :element new-element)
    (tset new-owner-clickable :type new-type)
    ))

(local clickable-mt {:__index clickable})

(fn clickable.create [_ x y {: pos : off : size : w : h : active : element : colliders : ox : oy : order &as value}]
  (let [ret {
             :pos {:x (or x (and pos pos.x)) :y (or y (and pos pos.y))}
             :size {:w (or w (and size size.w)) :h (or h (and size size.h))}
             :element (or element value.name)
             :type (or active value.type)
             : colliders
             :order (or order 0)
             }]
    (when (or off (and ox oy))
      (tset ret :off {:x (or ox (and off off.x)) :y (or oy (and off off.y))}))
    (setmetatable ret clickable-mt)
    (colliders:add ret)
    ret))
