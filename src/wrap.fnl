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
    (tset state :web true)
    (set _G.scale 3)
    (local (_width _height flags) (love.window.getMode))
    (love.window.setMode (* scale 400) (* scale 220) flags))

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
                                   (sound:setVolume 0.15)
                                   sound)
                                 "sprites/"
                                 (fn [image _filename]
                                   (image:setFilter :nearest :nearest)
                                   )
                                 }
                                }))

  (tset state :bgm (if state.web
                 (love.audio.newSource "assets/music/SadSpace.ogg" "static")
                 (. _G.assets.music "SadSpace")))

  (tset state :birds (if state.web
                   (love.audio.newSource "assets/sounds/birds.ogg" "static")
                   (. _G.assets.sounds "birds")))

  (tset state :fire (if state.web
                   (love.audio.newSource "assets/sounds/fire_crackling.ogg" "static")
                   (. _G.assets.sounds "fire_crackling")))

  (tset state :page  (love.audio.newSource "assets/sounds/page.ogg" "static"))

  (state.page:setVolume 0.2)
  (state.page:play)

  (state.bgm:setLooping true)
  (state.bgm:setVolume 0.25)
  (state.bgm:play)

  (state.birds:setLooping true)
  (state.birds:setVolume 0.25)
  ;;(state.fire:play)

  (state.fire:setLooping true)
  (state.fire:setVolume 0)
  (state.fire:play)



  (require :globals)
  (require :handlers)
  (gamestate.registerEvents)
  (gamestate.switch (require :mode-game) :wrap)
  (when (and state.dev (not state.web)) (repl.start)))
