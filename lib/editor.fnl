(local editor {})

(local buttons (require :lib.buttons))
(local gamestate (require :lib.gamestate))
(local params (require :params))
(local levels (require :levels))

(local state (require :state))

;; start customization

(local tile-size 16)

(local bursh-order [:ground :characters :houses :post-office :text :pack :chasm
                    ;; :player
                    ])

(local brush-canvas {:ground [(love.graphics.newCanvas 50 40)
                              (love.graphics.newCanvas 32 32)]
                     :chasm [(love.graphics.newCanvas 50 40)
                             (love.graphics.newCanvas 8 8)]
                     :characters [(love.graphics.newCanvas 50 40)
                                  (love.graphics.newCanvas 100 100)]
                     :houses [(love.graphics.newCanvas 50 40)
                              (love.graphics.newCanvas 200 200)]
                     :post-office [(love.graphics.newCanvas 50 40)
                                   (love.graphics.newCanvas 250 250)]
                     :text [(love.graphics.newCanvas  50 40)
                            (love.graphics.newCanvas  400 140)]
                     :pack [(love.graphics.newCanvas 50  40)
                            (love.graphics.newCanvas 100 100)]
                     ;;:player (love.graphics.newCanvas 32 32)
                     })

(local brushes {:ground [:ground]

                :chasm [:chasm]

                :characters [{:type :characters :name :k :unique true :w 16 :h 40}
                             {:type :characters :name :jill :unique true :w 16 :h 40}
                             {:type :characters :name :aly :unique true  :w 16 :h 40}
                             {:type :characters :name :sara :unique true :w 16 :h 40}
                             {:type :characters :name :tom :unique true  :w 16 :h 40}
                             {:type :characters :name :mike :unique true :w 16 :h 40}
                             {:type :characters :name :carl :unique true :w 16 :h 40}
                             {:type :characters :name :hank :unique true :w 16 :h 40}]

                :houses [{:type :houses :name :k :unique true :w 80 :h 80 :chim [54 15]}
                         {:type :houses :name :jill :unique true  :w 80 :h 80 :chim [22 15]}
                         {:type :houses :name :aly :unique true  :w 80 :h 80 :chim [24 15]}
                         {:type :houses :name :sara :unique true :w 80 :h 80 :chim [24 23]}
                         {:type :houses :name :tom :unique true :w 80 :h 80 :chim [62 10]}
                         {:type :houses :name :mike :unique true :w 80 :h 80 :chim [22 10]}
                         {:type :houses :name :carl :unique true :w 80 :h 80 :chim [57 10]}
                         {:type :houses :name :hank :unique true :w 80 :h 80 :chim [10 12]}]

                :post-office [{:type :post-office :w 160 :h 80 :unique true}]

                :text [{:type :text :number 1 :unique true :w 200 :h 336}
                       {:type :text :number 2 :unique true :w 200 :h 336}
                       {:type :text :number 3 :unique true :w 200 :h 336}
                       {:type :text :number 4 :unique true :w 200 :h 336}
                       {:type :text :number 5 :unique true :w 200 :h 336}
                       {:type :text :number 6 :unique true :w 200 :h 336}
                       {:type :text :number 7 :unique true :w 200 :h 336}
                       {:type :text :number 9 :unique true :w 200 :h 336}
                       {:type :text :number 10 :unique true :w 200 :h 336}
                       {:type :text :number 11 :unique true :w 200 :h 336}
                       {:type :text :number 12 :unique true :w 200 :h 336}
                       {:type :text :number 13 :unique true :w 200 :h 336}
                       {:type :text :number 14 :unique true :w 200 :h 336}
                       {:type :text :number 15 :unique true :w 200 :h 336}
                       {:type :text :number 16 :unique true :w 200 :h 336}
                       {:type :text :number 17 :unique true :w 200 :h 336}
                       {:type :text :number 18 :unique true :w 200 :h 336}
                       {:type :text :number 19 :unique true :w 200 :h 336}
                       {:type :text :number 20 :unique true :w 200 :h 336}
                       ]

                :pack [{:type :pack :number :k :unique true}
                       {:type :pack :number :jill :unique true}
                       {:type :pack :number :aly :unique true}
                       {:type :pack :number :sara :unique true}
                       {:type :pack :number :tom :unique true}
                       {:type :pack :number :mike :unique true}
                       {:type :pack :number :carl :unique true}
                       {:type :pack :number :hank :unique true}
                       {:type :pack :number :p1 :unique true}
                       {:type :pack :number :p2 :unique true}
                       {:type :pack :number :p3 :unique true}
                       {:type :pack :number :p4 :unique true}]
                })

(local type-to-index {:ground :ground
                      :chasm :chasm
                      :characters :characters
                      :houses :characters
                      :post-office :post-office
                      :pack :pack
                      :text :text
                      })

(local brush-index     {:ground 1
                        :characters 1
                        :post-office 1
                        :chasm 1
                        :text 1
                        :pack 1})

(local brush-index-max {:ground 1
                        :characters 8
                        :post-office 1
                        :chasm 1
                        :text 20
                        :pack 12})

(var brush-type :ground)

(local elements
       [;; {:type :button :y 680 :oy -4 :ox 600 :w 60 :h 30 :text "Back" }
        {:type :button :y 10 :oy -10 :ox 539 :w 50 :h 40 :text "G" :brush :ground}
        {:type :button :y 10 :oy -10 :ox 489 :w 50 :h 40 :text "E" :brush :chasm}
        {:type :button :y 10 :oy -10 :ox 439 :w 50 :h 40 :text "C" :brush :characters}
        ;;{:type :button :y 10 :oy -10 :ox 439 :w 50 :h 40 :text "P" :brush :player}
        {:type :button :y 10 :oy -10 :ox 389  :w 50 :h 40 :text "K" :brush :pack}
        {:type :button :y 10 :oy -10 :ox 339  :w 50 :h 40 :text "O" :brush :post-office}
        {:type :button :y 10 :oy -10 :ox 289  :w 50 :h 40 :text "H" :brush :houses}
        {:type :button :y 10 :oy -10 :ox 239  :w 50 :h 40 :text "T" :brush :text}
        {:type :button :y 10 :oy -10 :ox 39 :w 50 :h 40 :text "[" }
        {:type :button :y 10 :oy -10 :ox -11 :w 50 :h 40 :text "]" }
        ;; {:type :button :y 10 :oy -10 :ox -66 :w 60 :h 40 :text "Save"}
        ;; {:type :button :y 10 :oy -10 :ox -218 :w 244 :h 40 :text "Load from Clipboard"}
        ;; {:type :button :y 10 :oy -10 :ox -390 :w 100 :h 40 :text "Revert"}
        ;; {:type :button :y 10 :oy -10 :ox -490 :w 100 :h 40 :text "Next"}
        ;; {:type :button :y 10 :oy -10 :ox -590 :w 100 :h 40 :text "Previous"}
        ;;{:type :button :y 10 :oy -10 :ox -126 :w 300 :h 40 :text "Copy To Clipboard"}
        ;; {:type :button :y 10 :oy -10 :ox 600 :w 60 :h 30 :text "Load from Clipboard"}

        ])

(fn editor.keypressed [self key code state]
  (match key
    :g (set-brush :ground)
    :e (set-brush :chasm)
    :c (set-brush :characters)
    ;; :3 (set brush-type :player)
    :k (set-brush :pack)
    :o (set-brush :post-office)
    :h (set-brush :houses)
    :t (set-brush :text)
    "[" (decrement-brush brush-type)
    "]" (increment-brush brush-type)
    ;; :p (save state)
         ;;(state.level.save state.level state.level.map (.. state.current-level ".fnl"))
    ;; :c (save state :copy-to-clipboard)
    ;; :. (levels.next state)
    ;; :l (do
    ;;      (local levels (require :levels))
    ;;      (levels.load state state.current-level :from-clipboard))

    )
  )

(local element-click
       {"G" (fn [] (set brush-type :ground))
        "E" (fn [] (set brush-type :chasm))
        "C" (fn [] (set brush-type :characters))
        ;; "P" (fn [] (set brush-type :player))
        "K" (fn [] (set brush-type :pack))
        "H" (fn [] (set brush-type :houses))
        "O" (fn [] (set brush-type :post-office))
        "T" (fn [] (set brush-type :text))
        "[" (fn [] (decrement-brush brush-type))
        "]" (fn [] (increment-brush brush-type))
        "Back"
        (fn []
          (assets.sounds.page:play)
          (if state.editor
                (do (tset state :editor false)
                    ;;(love.mouse.setVisible false)
                    )
                (do (tset state :editor true)
                    ;;(love.mouse.setVisible true)
                    )))
        "Save"
        (fn [] (save state :copy-to-clipboard))
        "Load from Clipboard"
        (fn [] (levels.load-from-clipboard state))
        "Revert"
        (fn [] (levels.revert state))
        "Next"
        (fn [] (levels.next state))
        "Previous"
        (fn [] (levels.previous state))
        })

;; end customization

(local element-font
       {:title  ((. assets.fonts "inconsolata") 100)
        :subtitle  ((. assets.fonts "inconsolata") 40)
        :button  ((. assets.fonts "inconsolata") 20)
        :small-text  ((. assets.fonts "inconsolata") 20)})

(fn update-brushes [state]
  (local params (require :params))
  (local pointer state.pointer)
  (local objects (require :objects))
  (local main-canvas (love.graphics.getCanvas))
  (each [_ brush-type (pairs bursh-order)]
    (local brush (. brushes brush-type (. brush-index (. type-to-index brush-type))))
    (local small-canvas (. brush-canvas brush-type 1))
    (local large-canvas (. brush-canvas brush-type 2))
    (love.graphics.push)
    (love.graphics.setCanvas small-canvas)
    (love.graphics.clear)
    (love.graphics.setColor 1 1 1 1)
    (if (= :string (type brush))
        (if (= :chasm brush)
            (do
              (love.graphics.setColor params.colours.sky)
              (love.graphics.rectangle "fill" 5 5 40 30)
              (love.graphics.setColor 1 1 1 1))
            (do
              (state.level.hover state.level brush pointer.i pointer.j)
            (love.graphics.draw state.level.hover-batch 0 0 0 2)))
        (let [ret (lume.clone brush)]
          (tset ret :x 0)
          (tset ret :y 0)
          (local obj (objects.gen-object ret))
          (when (~= obj {})
            (tset obj :index 1)
            (when obj.draw (obj:draw {:x 0 :y 0 :scale 1} :editor))
            (love.graphics.push "all")
            (love.graphics.setCanvas large-canvas)
            (love.graphics.clear)
            ;; (love.graphics.setColor 1 1 1 0.3)
            (love.graphics.translate 50 50)
            (when obj.draw (obj:draw))
            (love.graphics.pop))
          ))
    (love.graphics.pop))
  (love.graphics.setCanvas main-canvas))


(fn decrement-brush [brush-type]
  (db (.. "decrement " brush-type " " (. type-to-index brush-type)))
  (tset brush-index (. type-to-index brush-type)
        (math.max 1 (- (. brush-index (. type-to-index brush-type)) 1)))
  (update-brushes state))

(fn increment-brush [brush-type]
  (db (.. "increment " brush-type " " (. type-to-index brush-type)))
  (tset brush-index (. type-to-index brush-type)
        (math.min (. brush-index-max (. type-to-index brush-type))
                  (+ (. brush-index (. type-to-index brush-type)) 1)))
  (update-brushes state))

(fn save [state copy-to-clipboard?]
  ;; (tset (. state.level.map.data.players "sheep one") :x state.sheep-1.x)
  ;; (tset (. state.level.map.data.players "sheep one") :y state.sheep-1.y)
  (tset state.level.map.data.players.steve :x state.steve.x)
  (tset state.level.map.data.players.steve :y state.steve.y)
  (_G.assets.sounds.click:play)
  (if (love.filesystem.isFused)
      (state.level:save state.level.map
                        (..
                         (love.filesystem.getSaveDirectory)
                         "/"
                         (or state.current-level "data-new-level") ".fnl")
                        copy-to-clipboard?)
      (state.level:save state.level.map
                        (.. "assets/levels/" (or state.current-level "data-new-level") ".fnl")
                        copy-to-clipboard?)))


(local element-hover {:button (fn [element x y] :nothing)})

(local ui (buttons elements params element-click element-hover element-font))

(fn editor.mousereleased [self x y button state]
  (local {: level : canvas : quad : world : camera : pointer} state)
  (local [cx cy] [(- (/ (- x 0) camera.scale) camera.x)
                   (- (/ (- y 0) camera.scale) camera.y)])

  ;; (local [cx cy] [x y])
  (local click-up {:i (math.floor (/ cx (* tile-size 1)))
                   :j (math.floor (/ cy (* tile-size 1)))
                   :button button})
  (local ui-hit (if state.editor (ui:mousereleased x y button) false))
  (when (not ui-hit)
    (if (= click-up.button 1)
        (do
          (tset level :brush (. brushes brush-type (. brush-index (. type-to-index brush-type))))
          (local end-y (math.max click-up.j state.click-down.j))
          (local start-y (math.min click-up.j state.click-down.j))
          (local end-x (math.max click-up.i state.click-down.i))
          (local start-x (math.min click-up.i state.click-down.i))
          (if (= :string (type level.brush) )
              (do
                  (level.add-tile-region level
                                         (math.floor (/ start-x 2))
                                         (math.floor (/ end-x 2))
                                         (math.floor (/ start-y 2))
                                         (math.floor (/ end-y 2))))
              (level.add-tile state.level click-up.i click-up.j true)))
        (level.remove-object state.level cx cy)))
  (tset state :click-down nil))

(fn editor.mousepressed [self x y button state]
  (local {: camera : pointer} state)
    (local [cx cy] [(- (/ (- x 0) camera.scale) camera.x)
                    (- (/ (- y 0) camera.scale) camera.y)])

  ;; (local [cx cy] [x y])
  (tset state  :click-down {:i (math.floor (/ cx (* tile-size 1)))
                            :j (math.floor (/ cy (* tile-size 1)))
                            :button button}))
  ;; (tset state :click-down
  ;;       {:i
  ;;        (math.floor (/ (+  (* pointer.i 8) camera.x) camera.scale))
  ;;        ;;(math.floor (/ (- (/ (- x offsets.x) camera.scale) camera.x) (* 8 1)))
  ;;        :j
  ;;        (math.floor (/ (+ (* pointer.j 8 (/ 1 camera.scale))  camera.y) 1))
  ;;        ;;(math.floor (/ (- (/ (- y offsets.y) camera.scale) camera.y) (* 8 1)))
  ;;         :button button}))


(fn set-brush [brush]
  (set brush-type brush)
  (update-brushes state))

(var first true)
(fn editor.update [dt]
  (when first (update-brushes state) (set first false))
  ;; (love.mouse.setVisible true)
  (ui:update dt)
  )

(fn editor.draw [state]
  (local objects (require :objects))
  (local camera state.camera)
  (local pointer state.pointer)
  (local params (require :params))
  (local brush (. brushes brush-type (. brush-index (. type-to-index brush-type))))

  (love.graphics.setColor params.colours.red)
  (love.graphics.rectangle "line"
                           (* (+ (* tile-size pointer.i) camera.x) camera.scale)
                           (* (+ (* tile-size pointer.j) camera.y) camera.scale)
                           ;; (math.floor (* (+ (* pointer.i 8) camera.x) camera.scale))
                           ;; (math.floor (* (+ (* pointer.j 8) camera.y) camera.scale))
                           ;; (* tile-size camera.scale)
                           ;; (* tile-size camera.scale)
                           (* camera.scale tile-size)
                           (* camera.scale tile-size)
                           20)

  (love.graphics.push "all")
  (love.graphics.setColor 1 1 1 0.3)
  ;; (love.graphics.translate -50 -50)
  (love.graphics.draw
   (. brush-canvas brush-type 2)
   (* (+ (* tile-size pointer.i) -50 camera.x) camera.scale)
   (* (+ (* tile-size pointer.j) -50 camera.y) camera.scale)
   0
   camera.scale
   )
  (love.graphics.pop)
  ;; headbar
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.rectangle "fill" 0 0 1280 40)
  (love.graphics.rectangle "fill" 0 0 74 74)
  (ui:draw) ;; images are overlayed
  ;; Active brush
  (love.graphics.setColor 1 1 1 1)
  (when state.slow-mo
   (update-brushes state))
  (love.graphics.draw (. brush-canvas brush-type 1) 12 12 0 1 1)

  (local (w h _) (love.window.getMode))
  (local px (/ params.screen-width 2))
  ;; (local w2 (math.floor (/ w 2)))
  (each [_ element (ipairs elements)]
    (when element.brush
      (local x (- px (+ element.ox (/ element.w 2))))
      (love.graphics.draw (. brush-canvas element.brush 1) (+ x 0) 0 0 1)
      ))
  (love.graphics.setColor 1 1 1 1))


editor
