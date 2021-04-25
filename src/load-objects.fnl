(fn make-object [name ...]
  ((require (.. :prefab- name)) ...))

(fn instantiate-object [state name ...]
  (tset state.objects name (make-object name ...)))

(fn []
  (let [state (require :state)
        aseprite (require :aseprite)
        atlas (aseprite "assets/data/Blocks.json" assets.sprites.Blocks)
        ship-atlas (aseprite "assets/data/Ships.json" assets.sprites.Ships)
        colliders (. (require :state) :colliders)
        prefab-slot (require :prefab-slot)]
    (instantiate-object state :player atlas 82 172 {: colliders : prefab-slot})
    (instantiate-object state :anvil atlas 140 175 {: colliders : prefab-slot})
    (instantiate-object state :materializer atlas 32 160 {: colliders : prefab-slot})
    (instantiate-object state :furnace atlas 60 136 {: colliders : prefab-slot})
    (instantiate-object state :table-shape atlas 64 198 {: colliders : prefab-slot})
    (instantiate-object state :table-pre atlas 92 156 {: colliders : prefab-slot})
    (instantiate-object state :etcher atlas 180 155 {: colliders : prefab-slot})
    (instantiate-object state :quencher atlas 180 190 {: colliders : prefab-slot})
    (instantiate-object state :table-work atlas 205 180 {: colliders : prefab-slot})
    (instantiate-object state :table-export atlas 232 156 {: colliders : prefab-slot})
    (instantiate-object state :table-hold atlas 232 198 {: colliders : prefab-slot})

    (instantiate-object state :table-enemy atlas 0 10 {: colliders : prefab-slot})

    (instantiate-object state :ship ship-atlas 40 96 {: colliders :table (. state :objects :table-export)})
    (instantiate-object state :enemy-ship ship-atlas 40 16 {: colliders :table (. state :objects :table-enemy) :setup :asteroids-1})

    (instantiate-object state :console atlas 144 8 {: colliders :note :intro})

    (instantiate-object state :starfield atlas 0 0 {:n 0 :s 0})

    (instantiate-object state :table-recipe atlas 384 20 {: colliders : prefab-slot})
    (instantiate-object state :node atlas 42 80 {:first :astroid})

    (instantiate-object state :mater-meter atlas 0 20)
    ))
