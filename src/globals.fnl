(var mute false)

(global toggle-sound
        (fn []
          (if mute
              (do
                (assets.sounds.click:play)
                (do (love.audio.setVolume 1) (set mute false)))
              (do  (love.audio.setVolume 0) (set mute true)))))

(global is-mute (fn [] mute))

(global set-mute (fn [in-mute]
                   (if in-mute
                         (do (love.audio.setVolume 0) (set mute true))
                         (do  (love.audio.setVolume 1) (set mute false)))))
