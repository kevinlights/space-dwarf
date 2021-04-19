(local anim8 (require "lib.anim8")) ;; only used for grid

(local subtile {})

(fn subtile.newGrid [...]
    (anim8.newGrid ...))

(fn subtile.square4 [sample-grid x y]
    (sample-grid x y x (+ 1 y) (+ x 1) y (+ 1 x) (+ 1 y)))

(fn subtile.square16 [sample-grid x y]
  (local [a b] [(+ x 2) (+ y 0)])
  (local [c d] [(+ x 4) (+ y 0)])
  (local [e f] [(+ x 6) (+ y 0)])
  (sample-grid x y x (+ 1 y) (+ x 1) y (+ 1 x) (+ 1 y)
               a b a (+ 1 b) (+ a 1) b (+ 1 a) (+ 1 b)
               c d c (+ 1 d) (+ c 1) d (+ 1 c) (+ 1 d)
               e f e (+ 1 f) (+ e 1) f (+ 1 e) (+ 1 f)))

(fn subtile.square10 [sample-grid x y]
  (local [a b] [(+ x 2) (+ y 0)])
  (sample-grid x y x (+ 1 y) (+ 1 x) y (+ 1 x) (+ 1 y)
               a       b a       (+ 1 b) a       (+ 2 b)
               (+ 1 a) b (+ 1 a) (+ 1 b) (+ 1 a) (+ 2 b)
               (+ 2 a) b (+ 2 a) (+ 1 b) (+ 2 a) (+ 2 b)))

(fn subtile.rect [sample-grid x y w h]
    (let [squares {}]
      (for [i 0 (- w 1)]
           (for [j 0 (- h 1)]
                (tset squares (+ 1 (# squares)) (+ x i))
                (tset squares (+ 1 (# squares)) (+ y j))))
      (sample-grid (unpack squares) )))

;; batchSprite <- love.graphics.neSpriteBatch
(fn subtile.batch [batchSprite size x y tile-table [tr tl br bl] ?offset-x]
    (local offset-x (or ?offset-x 0))
      (: batchSprite :add (. tile-table tr)
         (+ offset-x (* (* x 2) size)) (* (* y 2) size))
      (: batchSprite :add (. tile-table tl)
         (+ offset-x (* (+ (* x 2) 1) size)) (* (* y 2) size))
      (: batchSprite :add (. tile-table br)
         (+ offset-x (* (* x 2) size)) (* (+ (* y 2) 1) size))
      (: batchSprite :add (. tile-table bl)
         (+ offset-x (* (+ (* x 2) 1) size)) (* (+ (* y 2) 1) size)))

(fn subtile.batch-rect [batchSprite size x y tile-table w h map-width ?offset-x]
    (local offset-x (or ?offset-x 0))
    (var k 0)
    (var xp x)
    (for [i 0  (- w 1) ]
         (for [j 0 (- h 1)]
              (set k (+ 1 k))
              (if (>= (+ (* x 2) i) (* map-width 2))
                  (set xp (- x map-width))
                  (< (+ (* x 2) i) 0)
                  (set xp (- map-width x))
                  (set xp x))
              (: batchSprite :add (. tile-table k)
                 (+ offset-x (* (+ (* xp 2) i)  size)) (* (+ (* y 2) j)  size)))))

(fn subtile.fixed [...]
    [1 3 2 4])

(fn subtile.fence [type neigh]
    (let [sel
          (fn [x y] (let [xp (if (= x type) 1 0)
                          yp (if (= y type) 1 0)]
                      (+ 1 xp (* 2 yp))))
          a
          (. [1 1 5 5] (sel neigh.up neigh.left))
          b
          (. [3 3 7 7] (sel neigh.up neigh.right))
          c
          (. [2 10 14 6] (sel neigh.down neigh.left))
          d
          (. [4 12 16 8] (sel neigh.down neigh.right))]
      [a b c d]))


(fn subtile.blob [type neigh]
    (let [sel
          (fn [x y z]
            (let [xp (if (or (= x type) (= x :edge)) 1 0)
                  yp (if (or (= y type) (= y :edge)) 1 0)
                  zp (if (or (= z type) (= z :edge)) 1 0)]
              (+ 1 xp (* 2 yp) (* 4 zp))))
          a
          (. [5 6 5 6 8 4 8 9] (sel neigh.up neigh.up-left neigh.left))
          b
          (. [11 12 11 12 8 2 8 9] (sel neigh.up neigh.up-right neigh.right))
          c
          (. [7 6 7 6 10  3 10 9] (sel neigh.down neigh.down-left neigh.left))
          d
          (. [13 12 13 12 10 1 10 9] (sel neigh.down neigh.down-right neigh.right))]
      [a b c d]))


(local map {})

;; this should be wrapped into a library with subtile and
;; some of the logic from prefab-map
(fn map.update-tileset-batch [batch mapin layer]
  (: batch :clear)
  (local level (. mapin :data layer));;(or layers? [:sun :clouds :ground :objs]))
  (each [id tile (pairs (. mapin :data layer))]
    (when (not (= :square4 (. mapin.tile-set tile.type :size)) )
      (subtile.batch batch (/ mapin.tile-size 2)  tile.x  tile.y
                     (. mapin :tile-set tile.type :quad) tile.index))
   )
  (: batch :flush))

;; this is the only function with reference to
;; scale and camera. It maps pixels on the screen
;; to tiles in the map.
(fn map.xy-to-tile [[x y] tile-size]
  [(math.floor (/ (- x 0) (* 1 tile-size)))
   (math.floor (/ (- y 0) (* 1 tile-size)))])

(fn xy-to-id [x y width]
    (+ (* x width) y))

(fn id-to-xy [id width]
    [(math.floor (/ id width)) (math.floor (% id width))])

(fn map.create-quads [sample-grid tile-types]
  (each [key map (pairs tile-types)]
    (tset map :quad ((. subtile map.size) sample-grid (unpack map.pos))))
  tile-types)

(fn map.clear-quads [tile-types]
  (each [key map (pairs tile-types)]
    (tset map :quad nil))
  tile-types)

(fn map.to-sparse [mapin layer]
  (local {: type : map : data} (. mapin :data layer))
  (local sparse {})
  (when (= type "dense")
    (local off-y (or (. mapin :data layer :off-y) 0))
    (local off-x (or (. mapin :data layer :off-x) 0))
    (local range (or (. mapin :data layer :range)
                     {:minx 1 :miny 1 :maxx mapin.width :maxy mapin.height}))
    (var x 1)
    (var y 1)
    (for [i range.minx  range.maxx ]
      (for [j range.miny range.maxy ]
        (local type (. map (. data  x y)))
          (tset sparse  (+ (* i mapin.width) j )
                {:x i  :y j  : type})

          (set y (+ y 1))
          )
      (set y 1)
      (set x (+ x 1))
      )
    (tset (. mapin :data) layer sparse))
  mapin)


(fn map.to-dense [mapin layer default]
  (fn xy-to-index [x y] (+ (* x mapin.width) y))
  (local dense {:type "dense"})
  (local sparse (. mapin :data layer))
  ;; generate map
  (local type-map {})
  (var i 1)
  (var minx 300)
  (var maxx 1)
  (var miny 300)
  (var maxy 1)
  (each [key value (pairs sparse)]
    (when (~= value.type :chasm)
      (when (> value.x maxx) (set maxx value.x))
      (when (< value.x minx) (set minx value.x))
      (when (> value.y maxy) (set maxy value.y))
      (when (< value.y miny) (set miny value.y)))
    (when (= nil (. type-map value.type))
      (tset type-map value.type i)
      (set i (+ i 1))))
  ;; create a reversed map (temp)
  (local map-rev {})
  (each [key value (pairs type-map)]
    (tset map-rev value key))
  ;; sparse -> dense data
  (local data [])
  (set minx (- minx 1))
  (set maxx (+ maxx 1))
  (set miny (- miny 1))
  (set maxy (+ maxy 1))
  (var x 1)
  (var y 1)
  (for [i minx maxx]
    ;;(tset data i [])
    (tset data x [])
    (set y 1)
    (for [j miny maxy]
      (local value (or (. sparse (xy-to-index i j)) {:type (or default :chasm)}))
      ;;(tset (. data i) (+ 1 (- j miny)) (. type-map value.type))
      (tset (. data x) y (. type-map value.type))
      (set y (+ 1 y)))
    (set x (+ 1 x)))
  (tset dense :off-y (- miny 1))
  (tset dense :off-x (- minx 1))
  (tset dense :data data)
  (tset dense :map map-rev)
  (tset dense :range {: minx : maxx : miny : maxy})
  (tset (. mapin :data) layer dense)
  mapin)

(fn map.load [mapin]
  (local sample-grid (subtile.newGrid mapin.grid-size mapin.grid-size
                                      mapin.image-width mapin.image-height))
  (map.create-quads sample-grid mapin.tile-set)
  (map.to-sparse mapin :ground)
  (map.auto-index mapin :ground)
  mapin)

(fn map.add-tile [mapin x y l tile ?details]
    (var index (xy-to-id x y mapin.width))
    (when tile
      (tset tile :x x)
      (tset tile :y y)
      (tset tile :l l)
      (tset tile :id mapin.id)
      (tset map :id (+ mapin.id 1))
      (when ?details
        (each [key value (pairs ?details)]
          (tset tile key value))))
    (local replace (. mapin.data l index))
    (tset mapin.data l index tile)
    (values tile replace))

(fn map.remove [mapin x y l]
  (var index (xy-to-id x y mapin.width))
  (var tile nil)
  (when (. mapin.data l index)
    (set tile (lume.clone (. mapin.data l index))))
  (tset mapin.data l index nil)
    (values tile nil))

(fn map.replace [mapin x y l tile ?details]
  (map.remove mapin x y l)
  (map.add-tile mapin x y l tile ?details))

(fn neighbour [tiles width x y i j]
  (var max 0)
  (let [xp (+ x i)
        yp (+ y j)
        tile (. tiles (xy-to-id xp yp width))]
    (if tile
        (if tile.type
            (values tile.type :ok)
            (values :tile-missing-type :error ))
        (values :chasm :error))))

(fn get-neighbours [tiles x y width]
    (let [neighbour? (fn [i j] (neighbour tiles width x y i j))]
      {:right (neighbour? 1 0)
       :left (neighbour? -1 0)
       :up (neighbour? 0 -1)
       :down (neighbour? 0 1)
       :up-right (neighbour? 1 -1)
       :up-left (neighbour? -1 -1)
       :down-right (neighbour? 1 1)
       :down-left (neighbour? -1 1)}))

(fn neighbour-to-tile [x y direction]
  (let [neighbour? (fn [i j] {:x (+ x i) :y (+ y j)})]
    (match direction
      :right (neighbour? 1 0)
      :left (neighbour? -1 0)
      :up (neighbour? 0 -1)
      :down (neighbour? 0 1)
      :up-right (neighbour? 1 -1)
      :up-left (neighbour? -1 -1)
      :down-right (neighbour? 1 1)
      :down-left (neighbour? -1 1))
    ))

(fn map.auto-index [mapin layer]
  (local width mapin.width)
  (local tile-set mapin.tile-set)
  (local tiles (. mapin.data layer))
  (each [key tile (pairs tiles)]
    (local [type x y] [tile.type tile.x tile.y])
    (tset (. mapin.data layer key) :index
          ((. subtile (. tile-set type :auto)) type (get-neighbours tiles x y width))))
  mapin)

(fn map.newGrid [...]
  (subtile.newGrid ...))


;; (fn map.new []
;;   (local
;;    tile-set
;;    {:chasm {:layer :ground :pos [3 1] :size :square4 :auto :blob :collidable :fall}
;;     :ground {:layer :ground :pos [1 1] :size :square10 :auto :blob :collidable :fall}})
;;   (fn zeros [value number1 number2]
;;     (var ret [])
;;     (for [i 1 number1]
;;       (var sub [])
;;       (for [j 1 number2] (table.insert sub value))
;;       (table.insert ret sub))
;;     ret)
;;   (local mapin {:data {:ground {:type "dense"
;;                                 :map [:chasm :ground]
;;                                 :data (zeros 1 40 40)}
;;                        :objects {}
;;                        :players {"steve" {:x (* 32 5) :y (* 32 10) :name "steve"}
;;                                  }
;;                                  }
;;                 :width 40 :height 40 :id 0 :tile-size 32})
;;   (tset mapin :tile-set tile-set)
;;     (for [i 4 8]
;;       (for [j 20 23]
;;         (tset (. mapin.data.ground.data i) j  2)
;;         ))
;;     (map.load mapin)
;;   ;;(local quad (. mapin.tile-set :ground :quad))
;;   ;;(map.auto-index mapin :ground)
;;   need to set these! mapin.grid-size mapin.grid-size
;;                      mapin.image-width mapin.image-height
;;     mapin)

;;; EDITOR

(fn addremove [type mapin x y delete? hover? tileset?]
  (local layer (or hover? (. mapin.tile-set type :layer)))
  (local quad (. mapin.tile-set type :quad))
  (if (not delete?)
      (map.add-tile mapin x y layer {:type type :quad quad})
      (map.remove mapin x y layer)))

(local editor {})

(fn editor.update [self layer]
  (local {: tileset-batch  :map mapin} self)
  (map.update-tileset-batch tileset-batch mapin layer))

(fn editor.load-map [_self map-file? from-clipboard? revert?]
  (if from-clipboard?
      (do
        (local map-file (fennel.eval (love.system.getClipboardText)))
        (map.load map-file))
      revert?
      (map.load (fennel.eval (love.filesystem.read (.. "assets/levels/" map-file? ".fnl")) {}))
      map-file?
      (let [map-file (if (and (love.filesystem.isFused)
                              (love.filesystem.exists (.. map-file? ".fnl")))
                         (do (pp (.. "Game is Fused: Loading from " map-file? ".fnl"))
                             (fennel.eval (love.filesystem.read (.. map-file? ".fnl")) {}))
                         (require map-file?))]
        (map.load map-file))
      (do (map.new))))

(fn editor.add-tile [self x y interactive?]
  (let [{:map mapin
         : tileset-batch
         : brush
         } self]
    (if (= :string (type brush))
      (do (local (tile replace) (addremove brush mapin x y))
          (when interactive?
            (map.auto-index mapin :ground)
            (map.update-tileset-batch tileset-batch mapin :ground)
            (if replace
                (love.event.push :edit-map :replace-tile tile {:w 16 :h 16} replace)
                (love.event.push :edit-map :add-tile tile {:w 16 :h 16})))
          (values tile replace))
      (editor.add-object self brush x y))))

(fn editor.add-tile-region [self start-x end-x start-y end-y]
    (for [i start-x end-x]
      (for [j start-y end-y]
        (local (tile replace) (editor.add-tile self i j))
        (if replace
            (love.event.push :edit-map :replace-tile tile {:w 16 :h 16} replace)
            (love.event.push :edit-map :add-tile tile {:w 16 :h 16}))))
    (map.auto-index self.map :ground)
    (map.update-tileset-batch self.tileset-batch self.map :ground))

(fn editor.remove-tile [self brush x y]
    (let [{:map mapin
         : tileset-batch
         : tile-layers
         : brushes} self]
      (local tile (addremove brush mapin x y :delete))
      (local interactive? true)
    (when interactive?
      (map.auto-index mapin :ground)
      (map.update-tileset-batch tileset-batch mapin :ground)
      (love.event.push :edit-map  :remove-tile tile {:w 16 :h 16}))))

(fn editor.add-object [self obj x y]
  (var object-index (+ 1 (# self.map.data.objects)))
  (when obj.unique
    (each [index value (pairs self.map.data.objects)]
      (when (and (= value.colour obj.colour)
                 (= value.item obj.item)
                 (= value.name obj.name)
                 (= value.number obj.number)
                 (= value.type obj.type))
        (set object-index index)))
    )
  (local ret (lume.clone obj))
  (tset ret :x (* x 16))
  (tset ret :y (* y 16))
  ;; (editor.remove-object  self x y)
  (tset self.map.data.objects object-index ret)
  (love.event.push :edit-obj :add-object ret)
  (values ret nil))

(fn editor.remove-object [self x y]
  (local to-remove [])
  (each [index object (pairs self.map.data.objects)]
    (when (and (and (>= x object.x) (< x (+ (or object.w 16) object.x)))
               (and (>= y object.y) (< y (+ (or object.h 16) object.y))))
      (tset object :__index index)
      (table.insert to-remove object)))

  (when (> (# to-remove) 0)
    (local sort (. (require :objects) :sort))
    (local object (. (lume.sort to-remove sort)  (# to-remove)))
    (love.event.push :edit-obj :remove-object object)
    (tset self.map.data.objects object.__index nil))
  )

(fn editor.hover [self brush x y]
  (let [{: hover-batch} self]
    (local hovermap {:tile-set self.map.tile-set
                     :width self.map.width
                     :height self.map.height
                     :id 0
                     :tile-size 16
                     :data {:hover {}}})
    (local tile (addremove brush hovermap 0 0 nil :hover))
    (map.auto-index hovermap :hover)
    (map.update-tileset-batch hover-batch hovermap :hover)))

(fn editor.save [self mapin file copy-to-clipboard]
  (map.clear-quads mapin.tile-set)
  (map.to-dense mapin :ground)
  (local state (require :state))
  (tset mapin.data.players.steve :x state.steve.pos.x)
  (tset mapin.data.players.steve :y state.steve.pos.y)
  (tset mapin.data.players.steve :flipped state.steve.flipped)
  (let [f (assert (io.open (.. "assets/levels/" file ".fnl") "wb"))
        c (: f :write ((require "lib.fennelview") mapin))]
    (: f :close)
    c)
  (when copy-to-clipboard
    (local p (require :lib.fennelview))
    (local m (p mapin))
    (love.system.setClipboardText (m:gsub "%] %[" "%]\n%[")))
  (map.load mapin)
  nil)

(local editor-mt {
                  :__index editor
                  :__call editor.call
                  :update editor.update
                  :load-level editor.load-level
                  :add-tile editor.add-tile
                  :add-tile-region editor.add-tile-region
                  :remove-tile editor.remove-tile
                  :add-object editor.add-object
                  :remove-object editor.remove-object
                  :hover editor.hover
                  :save editor.save})


(fn editor.call [new-map-fn map-file tile-sheet from-clipboard? revert? options?]
  (tset map :new new-map-fn)
  (local mapin (editor.load-map nil map-file from-clipboard? revert?))
  (db :level-built)
  (fn tile-to-pixel [px tile-size]
    (* px tile-size))
  (local default
         {:tile-layers [:ground]
          :object-layers [:objs]
          :all-layers [:ground :objs]
          :grid-size 16
          :image-height 256
          :image-width 256
          })
  (each [key value (pairs (or options? {}))]
    (tset default key value))
  (local tileset-batch (love.graphics.newSpriteBatch
                        tile-sheet (* 400 400 4)))
  (local hover-batch (love.graphics.newSpriteBatch
                      tile-sheet 200))
  (local sample-grid
         (map.newGrid default.grid-size default.grid-size
                      default.image-width default.image-height))
  (local level
         (setmetatable
          {:tile-sheet tile-sheet
           :sample-grid sample-grid
           :map mapin
           :tile-size mapin.tile-size
           :map-width mapin.width
           :map-height mapin.height
           :tileset-batch tileset-batch
           :hover-batch hover-batch
           :level nil
           :object-layers default.object-layers
           :tile-layers default.tile-layers
           :all-layers default.all-layers
           :render true
           :over false
           :brush :fence
           } editor-mt))
  (editor.update level :ground)
  level)

editor
