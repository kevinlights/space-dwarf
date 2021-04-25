-- Scale the display (in lieu of a Fullscreen Option :/ )
local _width, _height, flags = love.window.getMode( )
local width, height = love.window.getDesktopDimensions( flags.display )
local maxWidth = math.floor(width / 400)
local maxHeight = math.floor((height - 80) / 220)
if (maxWidth > maxHeight)
then
   scale = maxHeight
end

if (maxWidth <= maxHeight)
then
   scale = maxWidth
end

love.window.setMode(scale * 400, scale * 220, flags)

-- bootstrap the compiler
local fennel_module = "lib.fennel"
fennel = require (fennel_module)
table.insert(package.loaders, fennel.make_searcher({correlate = true,
                                                    moduleName = fennel_module,
                                                    useMetadata = true,}))

package.loaded.fennel = fennel

fennel.path = love.filesystem.getSource() .. "/?.fnl;" ..
   love.filesystem.getSource() .. "/src/?.fnl;" ..
   love.filesystem.getSource() .. "/assets/levels/?.fnl;" ..
   fennel.path

-- package.path = "./src/?.lua;".. package.path

debug_mode = false
pp = function(x) print(require("lib.fennelview")(x)) end
db = function(x)
   if (debug_mode == true) then
      local debug_info = debug.getinfo(1)
      -- print debug.getinfo
      local currentline = debug_info.currentline
      -- local file = debug_info.source:match("^.+/(.+)$")
      local file = debug_info["short_src"] or ""
      local name = debug_info["namewhat"] or ""
      pp({"db", x})
   end
end

js = (require "lib.js")
lume = require("lib.lume")

-- taken from bump
function rect_isIntersecting(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and
         y1 < y2+h2 and y2 < y1+h1
end

_Gdata = {}
require("wrap")
