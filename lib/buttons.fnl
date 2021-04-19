(local buttons {})

(fn button-get-pos [element params]
  (local x (/ params.screen-width 2))
  [(+ element.cx (- x (+ element.ox (/ element.w 2))))
   (+ element.cy (+ element.oy element.y)) element.w element.h])

;; need to get font passed into these draw calls (put fonts in with elements)
;; need to get them to normalize to drawable screen

(fn element-draw-text [element params align?]
  (local align (or align? :center))
  ;; (local [x y w h] (button-get-pos element params))
  (love.graphics.setColor params.colours.text)
  (love.graphics.setFont  element.font)
  (if (and element.x element.align)
      (love.graphics.printf element.text
                            (+ 0;; element.cx
                               element.x)
                            (+ ;; element.cy
                             0
                             element.y)
                            params.screen-width element.align)
      (love.graphics.printf element.text
                            ;; element.cx
                            (or element.x 0)
                            (+ ;; element.cy
                             0
                               element.y)
                            params.screen-width align))
  )


(fn element-draw-textbox [element params]
  (love.graphics.setColor params.colours.text)
  (love.graphics.setFont element.font)
  (love.graphics.printf element.text
                        (/ (- params.screen-width element.w) 2)
                        element.y  element.w "left"))

(fn element-draw-button [element params]
  (local [px py w h] (button-get-pos element params))
  (local [x y] [(- px element.cx) (- py element.cy)])
  (if element.hovered
      (love.graphics.setColor params.colours.background)
      (love.graphics.setColor params.colours.text))
  (love.graphics.setFont  element.font )
  (love.graphics.printf element.text x (+ element.y 0 ;; element.cy
                                          ) w "center"))

(fn element-draw-animated-button [element params]
  (local [x y w h] (button-get-pos element params))
  (love.graphics.setColor params.colours.text)
  (love.graphics.setFont  element.font)
  (love.graphics.printf element.text (+ 10 x) element.y (- w 20) "left")
  (love.graphics.push)
  (local scale 4)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.scale scale scale)
  (let [animation (. element.animations element.anim) ]
    (animation.draw animation element.image
                    (math.floor (/  element.x  scale))
                    (math.floor (/ (- element.y 65) scale))))
  (love.graphics.pop)
  (love.graphics.setColor params.colours.text))

(local element-draw
       {:title
        (fn [element params]
          (element-draw-text element params))
        :subtitle
        (fn [element params]
          (element-draw-text element params))
        :text
        (fn [element params]
          (element-draw-text element params))
        :small-text
        (fn [element params]
          (element-draw-text element params))
        :small-text-left
        (fn [element params]
          (element-draw-text element params :left))

        :animated-button
        (fn [element params]
          (local [x y w h] (button-get-pos element params))
          (if element.hovered
              (do
                  (love.graphics.setColor params.colours.light-yellow)
                (love.graphics.rectangle "fill" x y w h)
                (element-draw-animated-button element params)
                (love.graphics.rectangle "line" x y w h))
              (do
                  (element-draw-animated-button element params)
                (love.graphics.rectangle "line" x y w h))))

        :button
        (fn [element params]
          (local [px py w h] (button-get-pos element params))
          (local [x y] [(- px element.cx) (- py element.cy)])
          (if element.hovered
              (do
                (love.graphics.setColor params.colours.light-yellow)
                (love.graphics.rectangle "fill" x y w h)
                (element-draw-button element params)
                (love.graphics.rectangle "line" x y w h))
              (do
                (love.graphics.setColor params.colours.white)
                (love.graphics.rectangle "fill" x y w h)
                (element-draw-button element params)
                (love.graphics.rectangle "line" x y w h))))

        :invisible-button
        (fn [element params]
          (local [px py w h] (button-get-pos element params))
          (local [x y] [(- px element.cx) (- py element.cy)])
          (when element.hovered
            (love.graphics.setColor params.colours.light-yellow)
            (love.graphics.rectangle "fill" x y w h)))
        })

;; relies on ANIM8 should be passed in
(local elements-update
       {:animated-button
        (fn [element dt]
          (tset element :anim
                (if element.hovered element.hovered-anim
                    element.not-hovered-anim))
          (let (animation (. element.animations element.anim))
            (tset element :animations element.anim :flippedH element.flipped)
            (animation.update animation dt)))})

;; needs to be passed into
;; (local elements-hover
;;        {:button
;;         (fn [element [x y] sounds]
;;           (sounds.click))
;;         :animated-button
;;         (fn [element [x y] sounds]
;;           (sounds.meaw))})

(fn update [self dt callback?]
  (local [cx cy] (buttons.c-offset self))
  (each [_ element (pairs self.elements)]
    (tset element :cy cy)
    (tset element :cx cx)
    (when callback?
      (callback? element dt))
    (let [update-fun (. elements-update element.type)]
      (when update-fun
        (update-fun element dt)))))

(fn hover [x y elements params]
  (each [_ element (pairs elements)]
    (when element.hover
      (local [ex ey ew eh] (button-get-pos element params))
      (if (and (> x ex) (< x (+ ex ew)) (> y ey) (< y (+ ey eh)))
          (when (not element.hovered)
            (tset element :hovered true)
            (element.hover element x y))
          (tset element :hovered nil)))))

(fn click [x y elements button params]
  (var was-anything-clicked? false)
  (each [_ element (pairs elements)]
    (when (or (= :button element.type)
              (= :invisible-button element.type)
              (= :animated-button element.type))
      (local [ex ey ew eh] (button-get-pos element params))
      (when (and button (> x ex) (< x (+ ex ew)) (> y ey) (< y (+ ey eh)))
        (element.click)
        (set was-anything-clicked? true))))
  was-anything-clicked?)

(fn buttons.draw [self]
  (each [_ element (ipairs self.elements)]
    ((. element-draw element.type) element self.params)))

(fn buttons.c-offset [self]
  (local (w h _) (love.window.getMode))
  (local { : w2 : h2} self.params)
  (local cx (math.max 0 (math.floor (-  (/ w 2) w2))))
  (local cy (math.max 0 (math.floor (-  (/ h 2) h2))))
  [cx cy]
  )

;; (buttons:update dt)
(fn buttons.update [self dt callbacks?]
  (local (ix iy) (love.mouse.getPosition))
  (local [x y] [ (/ (- ix offsets.gx) offsets.s) (/ (- iy offsets.gy) offsets.s)])
  (hover x y self.elements self.params)
  (update self dt  callbacks?))

(fn buttons.mousereleased [self x y button _ _]
  (click x y self.elements button self.params))

(fn buttons.mousepressed [self x y button _ _]
  false)

(fn buttons.keypressed [self key code]
  false)

(fn buttons.keyreleased [self key code]
  false)

;; love.mousepressed( x, y, button, istouch, presses )
(local button-mt
       {:__index buttons
        :update buttons.update
        :draw buttons.draw
        :c-offset buttons.c-offset
        :keypressed buttons.keypressed
        :keypressed buttons.keyreleased
        :mousepressed buttons.mousepressed
        :mousereleased buttons.mousereleased
        })

(fn new-ui [elements params? element-click? element-hover? element-font?]
  ;; (love.mouse.setVisible true)
  ;; merge everything down into just elements
  ;; params.colours.text
  ;; params.screen-width
  ;; params.colours.light-yellow
  (local params (or params? {}))
  (set params.colours (or params.colours {}))
  (set params.colours.light-yellow (or params.colours.light-yellow [1 1 0 1]))
  (set params.colours.text (or params.colours.text [1 1 1 1]))
  (set params.screen-width (or params.screen-width (love.window.getMode)))
  (tset params :w2 (or (/ params.screen-width 2) 0))
  (tset params :h2 (or (/ params.screen-height 2) 0))
  (local default-font (love.graphics.newFont 12))
  (local element-click (or element-click? {}))
  (local element-hover (or element-hover? {}))
  (local element-font (or element-font? {}))
  (each [_ element (pairs elements)]
    (let
        [id (or element.id element.text)
         type element.type
         click-callback  (or element.click
                             (. element-click id))
         hover-callback (or  element.hover
                             (. element-hover id)
                             (. element-hover type))
         font  (or  element.font
                    (. element-font id)
                    (. element-font type)
                    default-font)]
      (tset element :click click-callback)
      (tset element :hover hover-callback)
      (tset element :font font)
      (tset element :cx (or element.cx 0)) ;; canvas-x
      (tset element :cy (or element.cy 0)) ;; canvas-y
      ))
  ;; (tset elements :hover true)
  (setmetatable
   {:params params
    :elements elements}
   button-mt))
