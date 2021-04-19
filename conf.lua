love.conf = function(t)
   t.gammacorrect = true
   t.title, t.identity = "space-dwarf", "space-dwarf"
   t.modules.joystick = false
   t.modules.physics = false
   t.window.width = 1200
   t.window.height = 660
   t.window.vsync = true
   t.version = "11.3"
   t.window.fullscreentype = "desktop"-- "desktop" -- "exclusive"
   t.window.fullscreen = false
   t.window.minwidth = 1200
   t.window.minheight = 660
   t.window.resizable = false
   t.window.centered = true

   -- t.window.x = 0 -- Make sure to unset this
   -- t.window.y = 0 -- Make sure to unset this
end
