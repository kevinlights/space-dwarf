(local table-recipe {})

(fn table-recipe.draw [self]
  (love.graphics.draw self.image self.quad self.pos.x self.pos.y)
  (each [_ slot (ipairs self.slots)] (slot:draw nil nil true)))

(fn table-recipe.update [self dt]
  (each [_ slot (pairs self.slots)] (slot:update dt)))

(local table-recipe-mt {:__index table-recipe})

(fn create [atlas x y {: colliders : prefab-slot}]
  (let [quad (. atlas :quads "Blocks.aseprite" :recipe)
        slot1 (prefab-slot false atlas :table-recipe 1 (+ x 2) (- y 8) colliders)
        slot2 (prefab-slot false atlas :table-recipe 2 (+ x 2) (+ y 4) colliders)
        slot3 (prefab-slot false atlas :table-recipe 3 (+ x 2) (+ y 16) colliders)
        slot4 (prefab-slot false atlas :table-recipe 4 (+ x 2) (+ y 28) colliders)
        slot5 (prefab-slot false atlas :table-recipe 5 (+ x 2) (+ y 40) colliders)
        slot6 (prefab-slot false atlas :table-recipe 6 (+ x 2) (+ y 52) colliders)
        slot7 (prefab-slot false atlas :table-recipe 7 (+ x 2) (+ y 64) colliders)
        slot8 (prefab-slot false atlas :table-recipe 8 (+ x 2) (+ y 76) colliders)
        ;; slot10 (prefab-slot :F5 atlas :table-recipe (+ x 107) (- y 13) colliders)
        ret {:name :table-recipe
             :pos {: x : y}
             :size {:w 112 :h 8}
             :off  {:x 0 :y 0}
             : quad
             :slots [slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8]
             :h 12
             :w 114
             : colliders
             :type :col
             :image atlas.image}]
    (setmetatable ret table-recipe-mt)
    (tset ret :clickable ((require :prefab-clickable) nil (- x 1) (- y 3) ret))
    (ret.clickable:activate "table-recipe")
    (slot1:make :ceramic-armour)
    (slot2:make :laser)
    (slot3:make :shield)
    (slot4:make :capacitor)
    (slot5:make :point-defense)
    (slot6:make :mass-ordinance)
    (slot7:make :missile-launcher)
    (slot8:make :missile)
    (colliders:add ret)
    ret))
