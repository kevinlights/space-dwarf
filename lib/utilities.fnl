(fn atlas-to-new-quad [atlas]
  "e.g
(require :lib.loader)
(local atlas (loader.load-atlas :assets/data/atlas.png :assets/sprtes/ ))
(local new-quad (utilities.atlas-to-new-quad atlas))
(local (quad pivot data color) (new-quad :cat))
(local sample-obj {: quad :image atlas.image :x 10 :y 10})
(love.graphics.draw saple-obj.image sample-obj.quad sample-obj.x sample-obj.y)
"
  (let [width  (image:getWidth)
        height (image:getHeight)
        slices atlas.param.slices]
    (fn [member]
      (let [m (. slices member)
            {: x : y : w : h} (. m :keys :bounds)
            pivot (or (. m :keys :pivot) {:x 0 :y 0})
            data (or (. m :data) "")
            colour (or (. m :color) "#0000ffff")]
        (values (love.graphics.newQuad  x y w h width height) pivot data color)))))
