(local aseprite (require :aseprite))

(local state (require :state))

(local prefab-object (require :prefab-object))

(fn []
  (let [atlas (aseprite "assets/data/Blocks.json" assets.sprites.Blocks)]
    (tset state.objects :anvil (prefab-object atlas :AN 160 175))
    (tset state.objects :mt1 (prefab-object atlas :mt1 32 160  ))
    (tset state.objects :mt2 (prefab-object atlas :mt2 32 160))
    (tset state.objects :FR1 (prefab-object atlas :FR1 90 136  ))
    (tset state.objects :FU2 (prefab-object atlas :FU2 90 136))

    )
  )
