(global gamestate (require :lib.gamestate))
(global params (require :params))

(local repl (require :lib.stdio))
(local cargo (require :lib.cargo))

(require :lib.js)

(math.randomseed (os.time))

(local state (require :state))

(when (not false) (collectgarbage "stop"))

(fn love.load [args uargs]
  (when (= :web (. args 1))
    (tset state :web true))
  (love.graphics.setBackgroundColor params.colours.black)
  (love.filesystem.setIdentity "delivery-steve")
  (when (not (love.filesystem.getInfo (love.filesystem.getSaveDirectory)))
    (love.filesystem.createDirectory (love.filesystem.getSaveDirectory))
    (pp (.. (love.filesystem.getSaveDirectory) " created.")))
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (tset _G :assets (cargo.init {:dir :assets
                                :processors
                                {"sounds/"
                                 (fn [sound _filename]
                                   (sound:setVolume 0.1)
                                   sound)
                                 "sprites/"
                                 (fn [image _filename]
                                   (image:setFilter :nearest :nearest)
                                   )
                                 }
                                }))

  (local bgm (if state.web
                 (love.audio.newSource "assets/music/SadSpace.ogg" "static")
                 (. _G.assets.music "SadSpace")))
  (bgm:setLooping true)
  (bgm:setVolume 0)
  (bgm:play)

  (require :globals)
  (require :handlers)
  (gamestate.registerEvents)
  (gamestate.switch (require :mode-game) :wrap)
  (when (and state.dev (not state.web)) (repl.start)))
