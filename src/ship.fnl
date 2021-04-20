(fn ship-get-quads [atlas slice]
  (fn parse [str]
    (let (ret [])
      (each [value i (string.gmatch str "[0-9]+,[0-9]+,[0-9]+")]
        (let [mid []]
          (each [v i (string.gmatch value "[0-9]+")]
            (table.insert mid (tonumber v)))
          (table.insert ret mid))) ret))
  (let [hardpoints (parse (. atlas :info slice))
        count (# hardpoints)
        quads {:ship (. atlas :quads "Ships (Ships).aseprite" slice)
               :guns []
               :icons []}]
    (for [i 1 count]
      (tset quads.guns i (. atlas :quads (.. "Ships (Gun" i ").aseprite") slice))
      (tset quads.icons i  (. atlas :quads (.. "Ships (Icon" i ").aseprite") slice)))
    (values quads hardpoints count)))

(fn ship-update-weapons [ship active]
  (let [count ship.count
        slots ship.table.slots]
    ;; (set active [])
    (each [i slot (ipairs slots)]
      (when (and (= :finished slot.category) (= :laser slot.container.build) (< (# active) count))
        (table.insert active i)
        )
      )
    ))

{: ship-get-quads : ship-update-weapons}
