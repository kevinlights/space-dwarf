scale = 3

love.conf = function(t)
   t.gammacorrect = true
   t.title, t.identity = "space-dwarf", "space-dwarf"
   t.modules.joystick = false
   t.modules.physics = false
   t.window.width = (400 * scale)
   t.window.height = (220 * scale)
   t.window.vsync = true
   t.version = "11.3"
   t.window.fullscreentype = "desktop"-- "desktop" -- "exclusive"
   t.window.fullscreen = false
   t.window.minwidth = (400 * scale)
   t.window.minheight = (220 * scale)
   t.window.resizable = false
   t.window.centered = true

   -- t.window.x = 0 -- Make sure to unset this
   -- t.window.y = 0 -- Make sure to unset this
end
