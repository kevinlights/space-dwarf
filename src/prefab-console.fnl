(local console {})

(local mf math.floor)

(local notes (require :notes))
(local params {:padding 5
               :console-width 224
               :console-height 134
               :button-height 16
               :button-width 48
               :button-x (- 112 24)
               :title-font-size 10
               :text-font-size 7
               :button-font-size 7
               :button-buffer 4})

(var padding (* params.padding scale))
(var console-width (* params.console-width scale))
(var console-height (* params.console-height scale))
(var button-height (* params.button-height scale))
(var button-width (* params.button-width scale))
(var button-x (* params.button-x scale))
(var button-buffer (* params.button-buffer scale))

(var title-font (assets.fonts.fffforwa (* params.title-font-size scale)))
(var text-font (assets.fonts.inconsolata (* params.text-font-size scale)))
(text-font:setFilter :nearest :nearest)
(var button-font (assets.fonts.fffforwa (* params.button-font-size scale)))

(var title-height (title-font:getHeight))

(text-font:setLineHeight 1.4)

(fn draw-title [title]
  (when title.text
    (let [{: text : x : y : w} title]
      (love.graphics.setFont title-font)
      (love.graphics.printf text (mf x) (mf y) (mf w) :center))))

(fn draw-image [image]
  (when image.canvas
    (let [{: canvas : x : y } image]
      (love.graphics.draw canvas x y 0 scale))))

(fn draw-description [description]
  (when description.canvas
    (let [{: canvas : x : y : w : scroll : h : max-scroll} description]
      (love.graphics.draw canvas (mf x) (mf y))
      (when (> max-scroll 0)
        (let [ratio (/ h (+ h max-scroll))
              sh (* h ratio)];;(lume.clamp (* h ratio) h (/ h 3))]
          (love.graphics.rectangle "fill"
                                 (+ x console-width (- (* 3 padding)))
                                 (- y (* scroll ratio))
                                 (mf (/ padding 2))
                                 sh
                                 5)))
      )))

(fn draw-buttons [buttons]
  (when (> (# buttons) 0)
    (each [_ button (ipairs buttons)]
      (let [{: text : x : y : w : image : quad : off-y} button
            params (require :params)]
        (when button.hover (love.graphics.setColor 0 0.4 0.4 1))
        (love.graphics.draw image quad x y 0 scale)
        ;;(pp [button.element button.hover])
        (love.graphics.setColor 1 1 1 1)
        (tset button :hover false)
        (love.graphics.setFont button-font)
        (love.graphics.setColor params.colours.black)
        (love.graphics.printf text (mf x) (mf (+ y off-y)) (mf w) :center)
        (love.graphics.setColor 1 1 1 1)
        ))))

(fn draw-free-buttons [buttons]
  (each [key button (pairs buttons)]
    (button:draw)))

(fn initialize-title [text]
  {: text :x  padding :y padding :w (- console-width (* padding 2))})

(fn initialize-description [text image-height button-count colliders pos]
  (let [height (- console-height (* 2 padding) title-height
             (if image-height (+ image-height padding) 0)
             (* button-count (+ padding button-height)))
        width (- console-width (* 4 padding))
        y (+ (* 2 padding) title-height
             (if image-height (+ image-height padding) 0))
        font-height (text-font:getHeight)
        line-height (text-font:getLineHeight)
        (text-width rows) (text-font:getWrap text (- width padding))
        text-height (* (# rows) font-height line-height)
        canvas (love.graphics.newCanvas width height)
        prefab-clickable (require :prefab-clickable)
        ]
    (canvas:setFilter "nearest" "nearest")
    (love.graphics.setCanvas canvas)
    (love.graphics.setFont text-font)
    (love.graphics.printf text 0 0 (mf width) :left)
    (love.graphics.setCanvas)
    {: text
     :x padding
     :y y
     :w width
     :h height
     : text-height
     :scroll 0
     :max-scroll (math.max 0 (- text-height height))
     : canvas
     :clickable (prefab-clickable nil (+ pos.x (/ padding scale)) (+ pos.y (/ y scale)) {:w (/ (+ padding padding width) scale) :h (/ height scale) :active :click :element :description : colliders})}))

(fn initialize-buttons [buttons image-height description-height colliders pos]
  (let [ret []
        start-y (+ padding title-height
                        (if description-height (+ padding description-height) 0)
                        (if image-height (+ padding image-height) 0))
        ]
    (each [i button (ipairs buttons)]
      (let [canvas (love.graphics.newCanvas button-width button-height)
            aseprite (require :aseprite)
            prefab-clickable (require :prefab-clickable)
            atlas (aseprite "assets/data/Blocks.json" assets.sprites.Blocks)
            element (if (= :string (type button)) :close button.callback)
            text (if (= :string (type button)) button button.text)
            text-width (button-font:getWidth text)
            width (lume.clamp text-width button-width (- console-width (* 2 padding)))
            quad (. atlas :quads "Blocks.aseprite" (if (= button-width width)
                                                       :button
                                                       :wide-button))
            b {:text text
               :element element
               :y (+ start-y (* (- i 1) button-height) (* i padding))
               :off-y button-buffer
               :x (if (= button-width width) button-x (/ padding 3)) ;;(* 1 (/ (- console-width width padding) 2))
               :h button-height
               :w (if (= button-width width) button-width (- console-width (/ padding 3)))
               : quad
               :image atlas.image
               ;; :type :click
               }
            x (+ (/ b.x scale) pos.x)
            y (+ (/ b.y scale) pos.y)
            w (/ b.w scale)
            h (/ b.h scale)]
        (tset b :clickable (prefab-clickable nil x y {: w : h :active :click : element
                                                      : colliders}))

        (tset ret i b)))
    ret))

(fn initialize-free-buttons [free-buttons colliders console-pos]
  (let [functions {:activate (fn [self] (tset self :active true) (self.clickable:activate))

                   :deactivate (fn [self] (tset self :active false) (self.clickable:deactivate))
                   :draw
                   (fn [{: image : quad :pos {: x : y} : hover &as button}]
                     (when hover (love.graphics.setColor 0 0.4 0.4 1))
                     (set button.hover false)
                     (when button.active (love.graphics.draw image quad x y 0 scale))
                     (love.graphics.setColor 1 1 1 1))}
        functions-mt {:__index functions}
        ret {}
        aseprite (require :aseprite)
        prefab-clickable (require :prefab-clickable)
        atlas (aseprite "assets/data/Blocks.json" assets.sprites.Blocks)]
    (each [i {: text : pos :  size : callback} (pairs free-buttons)]
      (let [quad (. atlas :quads "Blocks.aseprite" text)
            b {:name text
               :active false
               : pos
               : size
               :element callback
               :image atlas.image
               : quad
               :clickable (prefab-clickable nil
                                            ;; console-pos.x
                                            ;; console-pos.y
                                            (+ (/ pos.x scale) console-pos.x)
                                            (+ (/ pos.y scale) console-pos.y)
                                            {:w size.w
                                             :h size.h
                                             :active :click
                                             :element callback
                                             : colliders})}]
        (pp [text quad])
        (tset ret i (setmetatable b functions-mt))))
    ret))

(fn remove-buttons [buttons colliders]
  (each [_ b (ipairs buttons)]
    (colliders:remove b)))

(fn initialize-image [image colliders pos]
  (let [aseprite (require :aseprite)
        prefab-clickable (require :prefab-clickable)
        atlas (aseprite "assets/data/Blocks.json" assets.sprites.Blocks)
        elements (if (= :string (type image)) [image] image)
        quads (lume.map elements (fn [element] (. atlas :quads "Blocks.aseprite" element)))
        areas (lume.reduce quads (fn [acc quad]
                                   (let [{:pos {:x px} :size {:w pw}}
                                         (if (> (# acc) 0)
                                             (. acc (# acc))
                                             {:pos {:x 0}  :size {:pw 0}})
                                         (x y w h) (quad:getViewport)]
                                     (table.insert acc {:pos {:x (+ (or pw 0) (or px 0))
                                                              :y 0}
                                                        :size { : w : h}})
                                     acc))
                                   [])
        width (lume.reduce areas (fn [acc area] (+ acc area.size.w)) 0)
        height (lume.reduce areas (fn [acc area] (if (> area.size.h acc) area.size.h acc)) 0)
        canvas (love.graphics.newCanvas width height)
        clickables {}]
    (love.graphics.setCanvas canvas)
    (each [i element (ipairs elements)]
      (let [area (. areas i)
            quad (. quads i)
            {:pos {: x} :size {: h}} area
            off (- height )]
        (tset area :element element)
        (tset area :type :click)
        (tset area.pos :y (mf (/ (- height h) 2)))
        (love.graphics.draw atlas.image quad x area.pos.y)
        (tset clickables i (prefab-clickable
                            nil
                            (+ pos.x x (mf (/ (- console-width (* scale width)) 2 scale)))
                            (+ pos.y area.pos.y (/ (+ padding padding title-height) scale))
                            {:w area.size.w
                             :h area.size.h
                             : colliders
                             :active :click
                             : element}
                            ))
        ))
    (love.graphics.setCanvas)
    {:x (mf (/ (- console-width (* scale width)) 2))
     :y (+ padding padding title-height)
     :h (* scale height)
     :areas  areas
     :canvas canvas
     : clickables}
    )
  )

(fn initialize-note [note colliders pos]
  (let [ret {}
        order [:title :image :description :buttons :keep-open]]
    (each [_  key (pairs order)]
      (let [value (. note key)]
        (tset ret key
              (if value
                  (match key
                    :title (initialize-title value)
                    :image (initialize-image value colliders pos)
                    :description (initialize-description value
                                                         ret.image.h
                                                         (or (and note.buttons (# note.buttons)) 0)
                                                         colliders
                                                         pos)
                    :buttons (initialize-buttons value
                                                 ret.image.h
                                                 ret.description.h
                                                 colliders
                                                 pos
                                                 )
                    :keep-open (do value)
                    _ nil)
                  {}))))
    ret))

(fn initialize-actions [ret colliders]
  (tset ret :actions (initialize-free-buttons
                        {:close {:text :x :pos {:x (- console-width (* scale (+ 4 8)) ) :y (* scale 6) } :size {:w 8 :h 8} :callback :close}
                         :previous {:text :previous :pos {:x (* scale 4 ) :y (* scale 6) } :size {:w 8 :h 8} :callback :previous}
                         :next {:text :next :pos {:x (* scale (+ 8 4 4) ) :y (* scale 6) } :size {:w 8 :h 8} :callback :next}}
                        colliders ret.pos ))
  ret)

(fn console.draw [self]
  (love.graphics.push)
  (love.graphics.scale scale)
  (love.graphics.draw self.background.image self.background.quad (/ self.pos.x 1) (/  (+ self.pos.y) 1))
  (love.graphics.pop)
  (love.graphics.push)

  ;; (love.graphics.scale (/ 1 scale))
  (love.graphics.translate (mf (* scale self.pos.x)) (mf (* scale self.pos.y)))
  (draw-title self.current-note.title)
  (draw-image self.current-note.image)
  (draw-description self.current-note.description)
  (draw-buttons self.current-note.buttons)
  (draw-free-buttons self.actions)
  (love.graphics.pop)
  )

(fn console.update [self]
  (let [drag (. (require :state) :drag)
        (x y) (love.mouse.getPosition)
        description (or self.current-note.description {})
        {: h : max-scroll} description]
    (when (and drag self.current-note.description)
      (let [ratio (/ h (+ h max-scroll))
            sh (* h ratio)]
        (tset (require :state) :drag y)
        ;; need to scale by ratio
        (self:wheelmoved 0 (/ (* 1 (- drag y)) ratio scale)))
      ;; (tset self.current-note.description :scroll (+ (/ (- drag y) scale)))
      )
    (when (and self.current-note self.current-note.buttons)
      (var map {})
      (each [_ button (pairs self.actions)]
        (tset map button.clickable.element button))
      (each [_ button (ipairs self.current-note.buttons)]
        (tset map button.clickable.element button))
      (self.colliders:check-hover x y map)))

  ;;
  (if (> (# self.history) 0)
      (self.actions.previous:activate)
      (self.actions.previous:deactivate))
  (if (> (# self.future) 0)
      (self.actions.next:activate)
      (self.actions.next:deactivate))
  (if (and (> (# self.history) 0) (~=  self.current-note.keep-open true))
      (self.actions.close:activate)
      (self.actions.close:deactivate)
      )
  )

(fn console.mousedown [self x y])

(fn console.mouseup [self x y])

(fn console.wheelmoved [self x y]
  (let [display (. self :current-note :description)]
    (when display
      (set display.scroll (lume.clamp (+ display.scroll (* 3 y)) (- display.max-scroll) 0 ))
      (love.graphics.setCanvas display.canvas)
      (love.graphics.clear)
      (love.graphics.setFont text-font)
      (love.graphics.printf display.text 0 display.scroll (mf display.w) :left)
      (love.graphics.setCanvas)
    ))
  )

(fn console.remove [self]
  (when (and self.current-note.description self.current-note.description.clickable)
    (self.current-note.description.clickable:remove))
  (when (and self.current-note.buttons)
    (each [_ button (ipairs self.current-note.buttons)]
      (when button.clickable
        (button.clickable:remove))))
  (when (and self.current-note.image self.current-note.image.clickables)
    (each [_ clickable (ipairs self.current-note.image.clickables)]
      (clickable:remove))))

(fn console.open [self note]
  (when (and (~= note self.note) (notes note))
    (self:remove)
    (table.insert self.history self.note)
    (for [i 0 (- (# self.future) 1)]
      (table.insert self.history (. self.future (- (# self.future) i))))
    (tset self :future [])
    (tset self :note note)
    (tset self :current-note (initialize-note (notes note) self.colliders self.pos))

    ))

(fn console.scale [self scale]
  (set padding (* params.padding scale))
  (set console-width (* params.console-width scale))
  (set console-height (* params.console-height scale))
  (set title-height (* params.title-height scale))
  (set button-height (* params.button-height scale))
  (set button-width (* params.button-width scale))
  (set button-x (* params.button-x scale))
  (set button-buffer (* params.button-buffer scale))

  (set title-font (assets.fonts.fffforwa (* params.title-font-size scale)))
  (set text-font (assets.fonts.inconsolata (* params.text-font-size scale)))
  (text-font:setFilter :nearest :nearest)
  (set button-font (assets.fonts.fffforwa (* params.button-font-size scale)))

  (set self.current-note (initialize-note (notes self.note) self.colliders)))

(fn console.center [self]
  (set self.pos.x (/ (- (* scale 400) console-width) 2 scale))
  (set self.pos.y 8)
  )

(fn console.move [self]
  (set self.pos.x 144)
  (set self.pos.y 8)
  )

(fn console.close [self]
  (when (> (# self.history) 0)
    (self:remove)
    (tset self :note (. self.history (# self.history)))
    (table.remove self.history (# self.history))
    (tset self :current-note (initialize-note (notes self.note) self.colliders self.pos))
    ))

(fn console.previous [self]
  (when (> (# self.history) 0)
    (self:remove)
    (table.insert self.future self.note)
    (tset self :note (. self.history (# self.history)))
    (table.remove self.history (# self.history))
    (tset self :current-note (initialize-note (notes self.note) self.colliders self.pos))
    []
    ))

(fn console.next [self]
  (when (> (# self.future) 0)
    (self:remove)
    (table.insert self.history self.note)
    (tset self :note (. self.future (# self.future)))
    (table.remove self.future (# self.future))
    (tset self :current-note (initialize-note (notes self.note) self.colliders self.pos))
    []
    ))

(fn console.clear [self note]
    (self:remove)
    (self:open note)
    (tset self :future [])
    (tset self :history [])
    )

(local console-mt {:__index console})

(fn create [atlas x y {: colliders : note}]
  (assert (notes note))
  (let [ret {:background {:image atlas.image
                          :quad (. atlas :quads "Blocks.aseprite" :Background)}
             :history []
             :note note
             :notes notes
             :future []
             :name :console
             :current-note (initialize-note (notes note) colliders {: x : y})
             :pos {: x : y}
             :colliders colliders
             :size {:w (/ console-width scale) :h (/ console-height scale)}
             }]
    (initialize-actions ret colliders)
    (setmetatable ret console-mt)
    ret
    )
  )
