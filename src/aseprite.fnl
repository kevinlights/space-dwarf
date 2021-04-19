(local aseprite {})

(fn aseprite.draw [self frame slice x y]
  (love.graphics.draw self.image (. self.quad frame slice) x y))

(local aseprite-mt {:__index aseprite})

(fn make-atlas [data-file image]
  (local json (require :lib.json))
  (let [data (json.decode (love.filesystem.read data-file))
        frame-data (. data :frames)
        source-size (. data :meta :size)
        slice-data  (. data :meta :slices)
        atlas {:image image :quads {} :info {} :size {}}]
    (each [frame-name frame-value (pairs frame-data)]
      (tset atlas.quads frame-name {})
      (local frame-bounds (. frame-value :frame))
      (each [_ slice-value (pairs slice-data)]
        (pp slice-value)
        (local slice-bounds (. slice-value :keys 1 :bounds))
        (pp slice-bounds)
        (local quad (love.graphics.newQuad
                     (+ slice-bounds.x frame-bounds.x)
                     (+ slice-bounds.y frame-bounds.y)
                     slice-bounds.w
                     slice-bounds.h
                     source-size.w
                     source-size.h))
        (tset (. atlas.quads frame-name) slice-value.name quad)
        (tset atlas.info slice-value.name (or slice-value.data ""))
        (tset atlas.size slice-value.name slice-bounds)
        )
      )
    (setmetatable atlas aseprite-mt)
    )
  )
