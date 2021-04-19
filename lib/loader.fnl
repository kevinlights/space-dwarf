(local loader
       {:_VERSION "Loader v0.3.0"
        :_DESCRIPTOIN "A wrapper for anim8 using Aseprite exports."
        :_DEPENDS [:json :anim8 :lume]
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

(local json (require :lib.json))
(local anim8 (require :lib.anim8))

(local sprite {})

(fn sprite.reset [sprite anim]
  "Set the current ANIM of SPRITE to 1."
  (: (. sprite.animations anim) :gotoFrame 1))

(fn sprite.update [sprite anim dt]
  "Use the anim8 update for ANIM of SPRITE."
  (: (. sprite.animations anim) :update dt))

(fn sprite.draw [sprite anim pos scale colour?]
  "Use the anim8 draw call for ANIM of SPRITE."
  (let [colour (or colour? [1 1 1 1])]
    (love.graphics.push "all")
    (love.graphics.setColor colour)
    (: (. sprite.animations anim) :draw
       sprite.image pos.x pos.y 0 scale)
    (love.graphics.pop)))

(local sprite-mt {:__index sprite})

(fn read-file [name]
    (love.filesystem.read name))

(fn write-file [file content]
    (let [f (assert (io.open file "wb"))
          c (: f :write ((require "lib.fennelview") content))]
      (: f :close)
      c))

(fn get-durations [param from to]
    (let [ret {}]
      (for [i from to]
           (tset ret (+ 1 (# ret))
                 (/ (. param.frames (+ 1 i) "duration") 1000)))
      ret ))

(fn loader.load-single [image-file data-file dev?]
  (local param
         (if dev?
             (do
               (let [ret (: json :decode (read-file (.. data-file ".json")))]
                 ;; (write-file (.. "assets/" file ".lua"))
                 ret))
             (lume.deserialize (love.filesystem.read (.. image-file ".lua")))))
  (local image (love.graphics.newImage (.. image-file ".png")))
  (local grid (anim8.newGrid 32 32 (: image :getWidth) (: image :getHeight)))
  (local animations {})
  (each [_ frame (ipairs param.meta.frameTags)]
    (tset animations frame.name
          (anim8.newAnimation (grid (.. (+ 1 frame.from) "-" (+ 1 frame.to)) 1)
                              (get-durations param frame.from frame.to))))
  {:animations animations :image image :grid grid :param param})

(fn loader.load-four [data-file image-folder width? height? offset-x? offset-y?]
  "Load an Aesprite sprite strip.

It expects the sprite to have four rows, one for each direction in the following
order: forward (down), right, backward (up), and left.

DATA-FILE the location of the JSON from the export. The loader expects
the data file to have the frame information and be in the array format.

IMAGE-FOLDER the folder to look for the image in. The image file name is
taken from the DATA-FILE meta information.

WIDTH an optional value for the width of each sprite in the sprite sheet. If
a value is not provided it defaults to 32px.

HEIGHT an optional value for the height of each sprite in the sprite sheet. If
a value is not provided it defaults to 32px."
  (local offset-x (or offset-x? 1))
  (local offset-y (or offset-y? 0))
  (local width (or width? 32))
  (local height (or height? 32))
  (local param ((. json :decode) (read-file (.. data-file ".json"))))
  (local image (love.graphics.newImage (.. image-folder "/" param.meta.image)))
  (local grid (anim8.newGrid width height (: image :getWidth) (: image :getHeight)))
  (local animations {})
  (local directions ["forward" "right" "backward" "left"])
  (local frame-length (/ param.meta.size.w width))
  (each [i dir (ipairs directions)]
        (each [_ frame (ipairs param.meta.frameTags)]
          (tset animations (.. dir "-" frame.name)
                (anim8.newAnimation (grid (.. (+ offset-x frame.from) "-" (+ offset-x frame.to)) (+ offset-y i))
                                    (get-durations param frame.from frame.to)))))
  (setmetatable {:animations animations :image image :grid grid :param param}
                sprite-mt))


(fn loader.load-atlas [data-file image-folder]
  (local param ((. json :decode) (read-file (.. data-file ".json"))))
  (local slices-array (or param.meta.slices []))
  (local slices {})
  (each [_ value (ipairs slices-array)]
    (tset slices value.name value))
  (local image (love.graphics.newImage (.. image-folder "/" param.meta.image)))
  {: image : param : slices})

loader
