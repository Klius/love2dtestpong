Menu = Drawable:extend()

function Menu:new()
  self.selectedOption = 1
  self.options = {
                  new = 1,
                  options = 2
                }
  self.subMenu = {
                    --score = 1,
                    audio = 1,
                    bigBall = 2,
                    smallBall = 3,
                    bigPaddle = 4,
                    smallPaddle = 5,
                    wall = 6,
                    confusion = 7,
                    back = 8
                    
                  }
  self.inOptions = false
  self.timeToMove = 0
  self.delay = 0.2
  x = love.graphics.getWidth()/2-75
  self.newGame = MenuOption(x,love.graphics.getHeight()/2,"Start Match",true, true)
  self.option = MenuOption(x,love.graphics.getHeight()/2+50,"Options",true, false)
  self.arrow = MenuDrawable(self.newGame.x-40, self.newGame.y, 32, 32, "assets/fletxa.png", 23)
  self.submenuchecks = self.getMenuChecks()
end

function Menu:getMenuChecks()
  x = love.graphics.getWidth()/2-75
  checks = {
            MenuCheck("Audio",x,150,config["sound"],"sound","Turn on/off the music"),
            MenuCheck("MaxiBall",x,200,config["pow-maxi-ball"],"pow-maxi-ball","Makes ball bigger"),
            MenuCheck("MiniBall",x,250,config["pow-mini-ball"],"pow-mini-ball","Makes ball smaller"),
            MenuCheck("MaxiPaddle",x,300,config["pow-maxi-pala"],"pow-max-pala","Makes player paddle bigger"),
            MenuCheck("MiniPaddle",x,350,config["pow-mini-pala"],"pow-mini-pala","Makes player paddle smaller"),
            MenuCheck("Wall",x,400,config["pow-wall"],"pow-wall","Creates a wall behind the goal"),
            MenuCheck("Confusion",x,450,config["pow-confusion-pala"],"pow-confusion-pala","Inverts Controls"),
            MenuOption( x, 500, "Back", true, false)
            }
  return checks
end

function Menu:draw()
    if self.inOptions then
      love.graphics.setColor(2,156,24,255)
      love.graphics.setFont(bigFont)
      love.graphics.print("OPTIONS", love.graphics.getWidth()/2-220, 0)
      love.graphics.setFont(mediumFont)
      for key,option in pairs(self.submenuchecks) do
        option:draw()
        --Subtitle
        if key == self.selectedOption then
          love.graphics.print(option.subtitle,love.graphics.getWidth()/2-150,100)
        end
      end
      self.arrow:draw()
    else
      love.graphics.setColor(2,156,24,255)
      love.graphics.setFont(bigFont)
      love.graphics.print("PÖNG", love.graphics.getWidth()/2-150, 50)
      self.newGame:draw()
      self.option:draw()
      self.arrow:draw()
    end
     love.graphics.print(self.selectedOption,0,0)
end
function Menu:update(dt)
  self.arrow:update(dt)
  self.timeToMove = self.timeToMove - dt
  if self.inOptions then
    self:subMenuUpdate(dt)
  else
    self:mainMenuUpdate(dt)
  end
end

function Menu:subMenuUpdate(dt)
  if love.keyboard.isDown("return") and self.timeToMove <= 0 then
    if self.selectedOption == self.subMenu.back then
      self.inOptions = false
      self.selectedOption = 2
      self:SaveConfig()
    else
      self.submenuchecks[self.selectedOption]:Check()
    end
    self.timeToMove = self.delay
  elseif love.keyboard.isDown("up") and self.timeToMove <= 0 then
    self.selectedOption = self.selectedOption - 1
    self.timeToMove = self.delay
    audioManager:PlayChime()
  elseif love.keyboard.isDown("down") and self.timeToMove <= 0 then
    self.selectedOption = self.selectedOption + 1
    self.timeToMove = self.delay
    audioManager:PlayChime()
  end
  
  if self.selectedOption < 1 then
    self.selectedOption = self.subMenu.back
  elseif self.selectedOption > self.subMenu.back then
    self.selectedOption = 1
  end
  
  self:subMenuDeselect()
  self.submenuchecks[self.selectedOption].selected = true
  self.arrow:changeVerticalPos(self.submenuchecks[self.selectedOption].y)
  for key,option in pairs(self.submenuchecks) do 
    option:Update()
  end
end

function Menu:subMenuDeselect()
  for key,option in pairs(self.submenuchecks) do 
    option.selected = false
  end
end
function Menu:mainMenuUpdate(dt) 
  if love.keyboard.isDown("return") and self.timeToMove <= 0 then
    if self.selectedOption == self.options.new then
      currentState = states.game
    elseif self.selectedOption == self.options.options then
      self.inOptions = true
      self.selectedOption = self.subMenu.audio
    end
    self.timeToMove = self.delay
  elseif love.keyboard.isDown("up") and self.timeToMove <= 0 then
    self.selectedOption = self.selectedOption - 1
    self.timeToMove = self.delay
    audioManager:PlayChime()
  elseif love.keyboard.isDown("down") and self.timeToMove <= 0 then
    self.selectedOption = self.selectedOption + 1
    self.timeToMove = self.delay
    audioManager:PlayChime()
  end
  
  if self.selectedOption < 1 then
    self.selectedOption = 2
  elseif self.selectedOption > 2 then
    self.selectedOption = 1
  end
  
  if self.selectedOption == self.options.new then
    self.newGame.selected = true
    self.option.selected = false
    self.arrow:changeVerticalPos(self.newGame.y)
  elseif self.selectedOption == self.options.options then
    self.newGame.selected = false 
    self.option.selected = true
    self.arrow:changeVerticalPos(self.option.y)
  end
end

function Menu:SaveConfig()
  for i=1,7 do
    self.submenuchecks[i]:Save()
  end
  --Write to config.js
    f = love.filesystem.newFile("config.js")
    f:open("w")
    f:write(json.stringify(config))
    f:close()
end

