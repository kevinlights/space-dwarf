(local movement
       {:_VERSION "Movement v0.2.0"
        :_DESCRIPTOIN "2D movement library."
        :_DEPENDS [:lume]
        :_URL "https://gitlab.com/alexjgriffith/allibs"
        :_LICENCE "
MIT LICENCE

Copyright (c) 2021 alexjgriffith

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the \"Software\"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."})

(fn check-key-down [key keys]
  (if (-> keys
          (. key)
          (lume.map love.keyboard.isDown)
          (lume.reduce (fn [a b] (or a b))))
      1
      0))

(fn sign0 [x]
    (if (= x 0) 0
      (> x 0) 1
      (< x 0) -1))

(fn movement.topdown [dt keys object]
  (let [r (check-key-down :right keys)
        l (check-key-down :left keys)
        u (check-key-down :up keys)
        d (check-key-down :down keys)
        lr (- r l)
        ud (- d u )
        speed object.speed
        pos object.pos
        max (if (and (~= 0 lr) (~= 0 ud)) speed.max-s2 speed.max)]
    (set speed.x (lume.clamp
                  (+ speed.x
                     (* dt (+ speed.decay speed.rate) lr)
                     (* dt (sign0 speed.x) (- speed.decay)))
                  (- max) max))
    (set speed.y (lume.clamp
                           (+ speed.y
                              (* dt (+ speed.decay speed.rate) ud)
                              (* dt (sign0 speed.y) (- speed.decay)))
                           (- max) max))
    (when (and (< (math.abs speed.x) (* (* dt 60)  speed.floor)) (= 0 lr) )
      (set speed.x 0))
    (when (and (< (math.abs speed.y) (* (* dt 60) speed.floor)) (= 0 ud))
      (set speed.y 0))
    (set pos.x (+ pos.x speed.x))
    (set pos.y (+ pos.y speed.y))
    (tset object :dir
          (match [r l u d]
            [1 _ _ _] :right
            [0 1 _ _] :left
            [0 0 1 _] :backward
            [0 0 0 1] :forward
            _ object.dir))
    (local moving? (> (+ l r u d) 0))
    (values pos.x pos.y object.dir moving?)))

(fn movement.default-speed []
  {:x 0 :y 0 :rate 20 :decay 5
   :max 10 :max-s2 (/ 10 (math.sqrt 2)) :floor 0.1})

movement
