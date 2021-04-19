(fn reset-gif [name time-step?]
  {
   :name name
   :max-frames 1000
   :active false
   :unique (os.time)
   :frame 0
   :time-step (or time-step? 0.1)
   :dt 0
   })

(local gif {})

(fn gif.stop [self]
    (set self.active false)
    ;; (os.execute
    ;;  (..
    ;;   "ffmpeg -y -i "
    ;;   (love.filesystem.getSaveDirectory)
    ;;   (string.format "/recording/%s_%s_" self.name self.unique)
    ;;   "%012d.png "
    ;;   "-framerate 10 "
    ;;   "-vf scale=480x270 "
    ;;   (love.filesystem.getSaveDirectory) "/" self.name "_" self.unique ".gif >"
    ;;   (love.filesystem.getSaveDirectory) "/" self.name "_" self.unique ".log 2>&1"
    ;;   ))
    ;; (love.filesystem.createDirectory (love.filesystem.getSaveDirectory) "/" self.name )
    ;; (os.execute (.. "mv"
    ;;                 (love.filesystem.getSaveDirectory)
    ;;                 "/recording/*.png"
    ;;                 " "
    ;;                 (love.filesystem.getSaveDirectory) "/" self.name))
    (os.execute
     (..
      "convert -delay 5 "
      (love.filesystem.getSaveDirectory)
      "/recording/*.png "
      (love.filesystem.getSaveDirectory) "/" self.name "_" self.unique ".gif >"
      (love.filesystem.getSaveDirectory) "/" self.name "_" self.unique ".log 2>&1"
      ))
    ;; (os.execute
    ;;  (.. "rm "
    ;;      (love.filesystem.getSaveDirectory)
    ;;      "/recording/*.png"))
    self)

(fn gif.update [self dt]
  (when  (= self.active true)
    (set self.dt (+ dt self.dt))
    (when (> self.dt self.time-step)
      (do
          (set self.frame (+ self.frame 1))
        (set self.dt (- self.dt self.time-step ))
        (love.graphics.captureScreenshot
         (string.format "recording/%s_%s_%012d.png"
                        self.name self.unique self.frame))))
    self)
    (when (> self.frame self.max-frames)
      (self:end)))

(fn gif.start [self]
  (local new-gif (reset-gif self.name self.time-step))
  (each [key value (pairs new-gif)]
    (tset self key value))
  (tset self :active true)
  self)

(local gif-mt
       {
        :__index gif
        :update gif.update
        :start gif.start
        :stop gif.stop
        })

(fn save-gifs [name time-step?]
  (local new-gif (reset-gif name time-step?))
  (setmetatable new-gif gif-mt))

save-gifs
