
function new_gamestate(width, height, scale)
   return {
	  player = {
		 controls = {
			keys = {}
		 },
		 position = {x = 200, y = 200},
		 direction = {x = 0, y = 0},
		 acceleration = {x = 0, y = 0}
	  },
	  tick = 0,
	  canvas = {},
	  window = {
		 width = width,
		 height = height,
		 internalResolutionWidth = width/scale,
		 internalResolutionHeight = height/scale,
		 scale = scale
	  }
   }
end

gamestate = new_gamestate(1920, 1080, 4)

function resize()
   w, h = love.graphics.getDimensions()
   gamestate.window.width = w
   gamestate.window.height = h
   gamestate.window.aspect_ratio = math.min(w/gamestate.window.internalResolutionWidth,h/gamestate.window.internalResolutionHeight)
end


function love.resize()
   resize()
end

function love.load()
   love.window.setMode(gamestate.window.width, gamestate.window.height, {resizable = true, vsync=1})
   love.graphics.setDefaultFilter('nearest', 'nearest')
   love.graphics.setLineStyle('rough')
   gamestate.canvas = love.graphics.newCanvas(gamestate.window.internalResolutionWidth,gamestate.window.internalResolutionHeight)
   love.graphics.setCanvas(gamestate.canvas)
   love.graphics.setDefaultFilter('nearest', 'nearest')
   love.graphics.setLineStyle('rough')
   love.graphics.setCanvas()


   gamestate.tileset = love.graphics.newImage("gfx/urizen_onebit_tileset__v2d0.png")

   resize()
end



function love.draw()
   love.graphics.setCanvas(gamestate.canvas)
   love.graphics.clear(0.1,0.2,0.1)

   local t = math.floor(gamestate.tick / 10)
   local x_index = t % 50
   local y = (x_index + (12* x_index))

   quad = love.graphics.newQuad(2,y+2, 12, 12, gamestate.tileset)
   love.graphics.draw(gamestate.tileset, quad, 50, 50)
   love.graphics.draw(gamestate.tileset, quad, 50+12, 50)

   love.graphics.push()
   love.graphics.translate(200,200)

   love.graphics.rotate(gamestate.tick/200)

   love.graphics.rectangle("fill", -50, -50, 100, 100)

   love.graphics.pop()
   love.graphics.print(gamestate.tick)




   love.graphics.setCanvas()
   -- do proper translate and scale before drawing to main window
   local s = gamestate.window.aspect_ratio
   love.graphics.translate(gamestate.window.width/2-((gamestate.window.internalResolutionWidth/2)*s),
                           gamestate.window.height/2-((gamestate.window.internalResolutionHeight/2)*s))
   love.graphics.scale(s,s)
   love.graphics.draw(gamestate.canvas)
end





function love.update(df)
   local keys = gamestate.player.controls.keys

   if keys["s"] == 1 then
      gamestate.player.position.y = gamestate.player.position.y + 1
   end
   
   if keys["escape"] == 1 then
      love.event.quit()
   end

   gamestate.tick = gamestate.tick + 1
end

function love.keypressed(key)
   gamestate.player.controls.keys[key] = 1
end

function love.keyreleased(key, scancode)
   gamestate.player.controls.keys[key] = 0
end

function love.mousepressed(x, y, button, istouch)
   local controls = gamestate.player.controls
   if button == 1 then controls.button1 = 1 end
   if button == 2 then controls.button2 = 1 end
end

function love.mousereleased(x, y, button, istouch, presses)
   local controls = gamestate.player.controls
   if button == 1 then controls.button1 = 0 end
   if button == 2 then controls.button2 = 0 end
end





function love.run()
   -- 1 / Ticks Per Second
   local TICK_RATE = 1 / 60
   -- How many Frames are allowed to be skipped at once due to lag (no "spiral of death")
   local MAX_FRAME_SKIP = 25

    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local lag = 0.0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Cap number of Frames that can be skipped so lag doesn't accumulate
        if love.timer then lag = math.min(lag + love.timer.step(), TICK_RATE * MAX_FRAME_SKIP) end

        while lag >= TICK_RATE do
            if love.update then love.update(TICK_RATE) end
            lag = lag - TICK_RATE
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
 
            if love.draw then love.draw() end
            love.graphics.present()
        end

        -- Even though we limit tick rate and not frame rate, we might want to cap framerate at 1000 frame rate as mentioned https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881
        if love.timer then love.timer.sleep(0.001) end
    end
end

