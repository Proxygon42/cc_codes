--[[
                  BATTLESHIP
                  By: Negeator
]]--
local monSide = "none"
local turn, selectX, selectY
local myName, opponentName
local menuSelect
-- message1 is what event just happened, message2 displays things
local message1, message2
local sendid --Computer ID to send to
local host --If we are hosting
local gamePlaying  --If the game is playing
local monSide = "none" --Monitor Side being used
local monitor --The monitor
local quit -- Did you or the other player quit in the middle of a game

os.pullEvent = os.pullEventRaw

--[[
Two grids are stored. One is the player's grid, the other is the opponent's.

"-" = Nothing
"H" = Hit
"S" = Sunk
"m" = Miss
"o" = The Player's Ships (only seen on the opponent's grid)
--]]

local myGrid =
{
  [1] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [2] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [3] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [4] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [5] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [6] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [7] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [8] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [9] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [10] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"}
}

local opponentGrid =
{
  [1] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [2] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [3] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [4] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [5] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [6] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [7] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [8] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [9] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [10] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"}
}

--[[
  Arrays for each of the player's ships
  Each ship has: {x,y,length, direction (0 = horizontal, 1 = vertical), is it sunk? (0 = false, 1 = true)}

--]]

local myShips =
{
  -- 2 Long Ships
  [1] = {0,0,2,0,0},
  -- 3 Long Ships
  [2] = {0,0,3,0,0},
  [3] = {0,0,3,0,0},
  -- 4 Long Ships
  [4] = {0,0,4,0,0},
  -- 5 Long Ship
  [5] = {0,0,5,0,0}
}

local opponentShips =
{
  -- 2 Long Ships
  [1] = {0,0,2,0,0},
  -- 3 Long Ships
  [2] = {0,0,3,0,0},
  [3] = {0,0,3,0,0},
  -- 4 Long Ships
  [4] = {0,0,4,0,0},
  -- 5 Long Ship
  [5] = {0,0,5,0,0}
}

local menuOptions =
{
  "Host",  "Join", "Help", "Exit"
}

--Reset the grids
function resetGrids()
opponentGrid =
{
  [1] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [2] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [3] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [4] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [5] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [6] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [7] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [8] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [9] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [10] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"}
}
myGrid =
{
  [1] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [2] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [3] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [4] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [5] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [6] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [7] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [8] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [9] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"},
  [10] = {"-", "-", "-", "-", "-", "-", "-", "-", "-", "-"}
}
end

--Reset the ships (whether they are destroyed or not) for the next game
function resetShips()
  for i = 1, #myShips do
        myShips[i][5] = 0
  end
  for i = 1, #opponentShips do
        opponentShips[i][5] = 0
  end
end

--Basic Draw Functions
function clearScreen()
  term.clear()
  term.setCursorPos(1,1)
end

function drawAt(x,y,text)
  term.setCursorPos(x,y)
  term.write(text)
end

--Basic Monitor Draw Functions

function clearMonitor()
  monitor.clear()
  monitor.setCursorPos(1,1)
end

function drawAtMonitor(x,y,text)
  monitor.setCursorPos(x,y)
  monitor.write(text)
end

-- Draw a Grid
function drawGrid(grid, startX)
  for a = 1, 10 do
        for b = 1, 10 do
          drawAt((a * 2) + startX,b,grid[b][a])
        end
  end

end

--Add's the player's ships to the opponent's grid
function addShips()
  for a = 1, #myShips do
        for b = 1, myShips[a][3] do
          if myShips[a][4] == 0 then  --Horizontal
         opponentGrid[ myShips[a][2] ] [ myShips[a][1] + b - 1 ] = "o"
          else --Vertical
         opponentGrid[ myShips[a][2] + b - 1 ] [ myShips[a][1] ] = "o"
          end
        end
  end
end

--Draw the ship seen on the menus
function drawArt()
  --Draw Some (Crappy) Ascii Art
  drawAt(1,7,"                            /|              _")
  drawAt(1,8,"                           | |________ / |")
  drawAt(1,9,"           ____ '--|_|/__/__|__|_____")
  drawAt(1,10,"___---__/        |__/_/_/_/__|-------______________")
  drawAt(1,11,"|                                                                                         /")
  drawAt(1,12, "_____________________________________________|")
end

--Draw Cursor
function drawCursor(x1,x2,y)
  drawAt(x1,y,"[")
  drawAt(x2,y,"]")
end

--Set Cursor Position
function setCursorPos(x,y)
  if x < 1 then
        x = 10
  elseif x > 10 then
        x = 1
  end
  if y < 1 then
        y = 10
  elseif y > 10 then
        y= 1
  end

  selectX = x
  selectY = y

end  

--How many ships are sunk
function getShipsSunk(ships)
  local amount = 0
  for a = 1, #ships do
        if ships[a][5] == 1 then
          amount = amount + 1
        end
  end
  return amount
end

--Check to see if there is a ship at the location
function checkForShip(x,y)
  local xx, yy
  for a = 1, #opponentShips do
        xx = opponentShips[a][1]
        yy = opponentShips[a][2]
        for b = 1, opponentShips[a][3] do
          if x == xx and y == yy then
         myGrid[yy][xx] = "H"
         message1 = "Hit!"
         if checkIfSunk(a) == 1 then
           setSunk(a)
           message1 = "Ship Sunk!"
         end
                        return 1
                  end
          
          if opponentShips[a][4] == 0 then
         xx = xx + 1
          else
         yy = yy + 1
          end
          
        end
  end
  return 0
end

--Check if the ship is sunk (called in checkForShip())
function checkIfSunk(index)
  local xx = opponentShips[index][1]
  local yy = opponentShips[index][2]

  for a = 1, opponentShips[index][3] do
         if myGrid[yy][xx] ~= "H" then
           return 0
         end
         if opponentShips[index][4] == 0 then
           xx = xx + 1
         else
           yy = yy + 1
         end
  end
  return 1
end

--Set a ship to sunk, and update the board
function setSunk(index)
  opponentShips[index][5] = 1

  local xx = opponentShips[index][1]
  local yy = opponentShips[index][2]
  rednet.send(sendID,"+"..tostring(index)) -- This tells the other computer to add to your shipsSunk counter
  for a = 1, opponentShips[index][3] do
         myGrid[yy][xx] = "S"
         rednet.send(sendID,tostring(xx).."|"..tostring(yy).."|"..myGrid[yy][xx].."|")
         if opponentShips[index][4] == 0 then
           xx = xx + 1
         else
           yy = yy + 1
         end
  end
end

--When you select a grid location
function selectLocation(selectX,selectY)
  if myGrid[selectY][selectX] == "-" then
        if checkForShip(selectX,selectY) == 1 then
         --Grid is set to "H" in checkForShip()
         rednet.send(sendID,tostring(selectX).."|"..tostring(selectY).."|"..myGrid[selectY][selectX].."|")
         turn = 1
        else
          myGrid[selectY][selectX] = "m"
          message1 = "Miss..."
          rednet.send(sendID,tostring(selectX).."|"..tostring(selectY).."|"..myGrid[selectY][selectX].."|")
          turn = 1
        end     
  else
        message1 = "Space is already taken."
  end
end

--Reading the in-game message send with rednet (x|y|symbol)
function readMessage(text)
  local xx = 1
  local yy = 1
  local symbol = "!"
  local counter = 0
  local temp = ""

  if string.sub(text,1,1) == "X" then
        quit = true
        gamePlaying = false
  elseif string.sub(text,1,1) == "+" then
        for i = 2, string.len(text) do
          temp = temp..string.sub(text,i,i)
        end
        myShips[tonumber(temp)][5] = 1
  else
        for i = 1, string.len(text) do
          if string.sub(text,i,i) ~= "|" then
                temp = temp .. string.sub(text,i,i)
          else
                drawAt(1,i,temp)
                if counter == 0 then
                  xx = tonumber(temp)
                elseif counter == 1 then
                  yy = tonumber(temp)
                else
                  symbol = temp
                end
          
                counter = counter + 1
                temp = ""
          end
        end
        opponentGrid[yy][xx] = symbol
        --Set Message 2
        if symbol == "m" then
          message2 = opponentName.." missed..."
        elseif symbol == "H" then
          message2 = opponentName.." hit a target!"
        elseif symbol == "S" then
          message2 = opponentName.." sunk a ship!"
        end
  end
end

--Draws the monitor
function monitorDraw()
  clearMonitor()
  --Draw opponentGrid
  for x = 1, 10 do
        for y = 1, 10 do
          --We don't want to draw our ship on the screen, that would be bad
          if opponentGrid[y][x] ~= "o" then
                drawAtMonitor( (x * 2) + 26,y,opponentGrid[y][x])
          else
         drawAtMonitor( (x * 2) + 26,y,"-")
          end
        end
  end
  --Draw myGrid
  for x = 1, 10 do
        for y = 1, 10 do
          drawAtMonitor(x * 2 ,y ,myGrid[y][x])
        end
  end

        --Draw Arrow for whose turn it is
        if turn == 0 then
          drawAtMonitor(22,3,"<-")
        else
          drawAtMonitor(26,3,"->")
        end
        
        -- Draw Vertical Bar
        for i = 1, 10 do
          drawAtMonitor(24,i,"|")
          drawAtMonitor(25,i,"|")
        end
        -- Draw Horizontal Bar
        drawAtMonitor(1,11,"==================================================================")
        drawAtMonitor(2,12,myName..":")
        drawAtMonitor(31,12,opponentName..":")
        drawAtMonitor(2,14,"Ships Sunk: "..getShipsSunk(opponentShips))
        drawAtMonitor(31,14,"Ships Sunk: "..getShipsSunk(myShips))
        -- Draw Horizontal Bar
        drawAtMonitor(1,15,"==================================================================")
        
        if turn == 0 then
          drawAtMonitor(1,16,"Turn: "..myName)
        else
          drawAtMonitor(1,16,"Turn: "..opponentName)
        end
end

--Draw function for the game
function gameDraw()
        if monSide ~= "none" then
          monitorDraw()
        end
        
        clearScreen()
        drawGrid(myGrid, 0)
        drawGrid(opponentGrid, 29)
        drawCursor((selectX * 2) - 1,(selectX * 2) + 1,selectY)
        
        --Draw Arrow for whose turn it is
        if turn == 0 then
          drawAt(23,3,"<-")
        else
          drawAt(27,3,"->")
        end
        
        -- Draw Vertical Bar
        for i = 1, 10 do
          drawAt(25,i,"|")
          drawAt(26,i,"|")
        end
        -- Draw Horizontal Bar
        drawAt(1,11,"==================================================================")
        drawAt(2,12,myName..":")
        drawAt(31,12,opponentName..":")
        drawAt(2,13,"Ships Sunk: "..getShipsSunk(opponentShips))
        drawAt(31,13,"Ships Sunk: "..getShipsSunk(myShips))
        -- Draw Horizontal Bar
        drawAt(1,14,"==================================================================")
        drawAt(1,15,message1)
        drawAt(1,16,message2)
        
        if turn == 0 then
          drawAt(1,17,"Turn: "..myName)
        else
          drawAt(1,17,"Turn: "..opponentName)
        end
        
        if quit == true then
          drawAt(1,18,"Game Terminated.")
        end
end

function checkForWinner()
  if getShipsSunk(opponentShips) >= #opponentShips then
        drawAt(1,18,myName.." WON!  :)/>/>")
        gamePlaying = false
  elseif getShipsSunk(myShips) >= #myShips then
        drawAt(1,18,opponentName.." WON!  :)/>/>")
        gamePlaying = false
  end
end

--Handles all of the game events
function gameEvents()
        event, p1, p2 = os.pullEvent()

        if event == "key" then
         if p1 == 200 then
           setCursorPos(selectX, selectY - 1)
                elseif p1 == 203 then
                  setCursorPos(selectX - 1, selectY)
                elseif p1 == 205 then
                  setCursorPos(selectX + 1, selectY)
                elseif p1 == 208 then
                  setCursorPos(selectX, selectY + 1)
                elseif p1 == 28 then
                  if turn == 0 then
                                        selectLocation(selectX,selectY)
                  end
                elseif p1 == 14 then
                  --Quit Game
                  rednet.send(sendID,"X")
                  quit = true
                  gamePlaying = false
                end
        elseif event == "rednet_message" then
          if p1 == sendID then
         readMessage(p2)
         turn = 0
          end
        elseif event == "terminate" then
          rednet.send(sendID,"X")
          quit = true
          gamePlaying = false
        end
end

--Play the game
function game()
  if host == true then
        turn = 0
  else
        turn = 1
  end
  selectX = 4
  selectY = 1
  message1 = ""
  message2 = ""
  quit = false  --If someone quits the game
  addShips()
  gamePlaying = true
  os.startTimer(.1)
  startMonitor() --Sets up the monitor if there is one
  while gamePlaying == true do
        gameEvents()
        gameDraw()
        checkForWinner()
  end
  drawAt(1,19,"Press Enter to Exit")
  while true do
        event, p1 = os.pullEvent()

        if event == "key" then
         if p1 == 28 then
           return
         end
         end
  end
end

--Check for a ship during the Ship Placement Process. 'amount' is the current ship you are one
function checkForShipPlacement(index)
  local xx, yy
  local x,  y
  x = myShips[index][1]
  y = myShips[index][2]

  for i = 1, myShips[index][3] do
        for a = 1, index - 1 do
          xx = myShips[a][1]
          yy = myShips[a][2]
          for b = 1, myShips[a][3] do
         if x == xx and y == yy then
           return false
                        end
        
                        --Adjust next place to test based on ship[a]'s direction
         if myShips[a][4] == 0 then
           xx = xx + 1
         else
           yy = yy + 1
         end
           end
        end
        --Adjust where to check next based on ship[i]'s direction
        if myShips[index][4] == 0 then
          x = x + 1
        else
          y = y + 1
        end
  end
  return true
end

--Check if a Ship (placing) Fits
function checkFit(index)
if myShips[index][4] == 0 then
        if myShips[index][1] + myShips[index][3] > 11 then
          message1 = "Does not fit on grid."
          return false
        end
  else
        if myShips[index][2] + myShips[index][3] > 11 then
          message1 = "Does not fit on grid."
          return false
        end
  end

  if checkForShipPlacement(index) == true then
        message1 = "Successfully placed."
        return true
  else
        message1 = "Overlaps another ship."
        return false
  end
end

--Add ships to the grid during the selectShips() function
function selectShipsAdd(currShip)
  local xx,yy
  for i = 1, currShip do
        xx = myShips[i][1]
        yy = myShips[i][2]
        for a = 1, myShips[i][3] do
          if xx <= 10 and yy <= 10 then
                opponentGrid[yy][xx] = "o"
          end
          
          if myShips[i][4] == 0 then
                xx = xx + 1
          else
                yy = yy + 1
          end
        end
  end

end

function selectShips()
  local placed
  local dir
  for i = 1, #myShips do
        placed = false
        selectX = 1
        selectY = 1
        dir = 0
        message1 = ""
        while placed == false do
          clearScreen()
          myShips[i][1] = selectX
          myShips[i][2] = selectY
          myShips[i][4] = dir
          
          drawAt(1,12,"Place Ship # "..i..": ")
          drawAt(1,13,"=================================================")
          drawAt(1,14,"Arrows - Move, Enter - Place, Crl - Rotate")
          drawAt(1,15,message1)
          resetGrids()
          selectShipsAdd(i)
          drawGrid(opponentGrid,0)
          drawCursor(selectX * 2 - 1, selectX * 2 + 1, selectY)
          
          
          event, p1 = os.pullEvent()
          if event == "key" then
        if p1 == 200 then
          setCursorPos(selectX, selectY - 1)
                elseif p1 == 203 then
          setCursorPos(selectX - 1, selectY)
        elseif p1 == 205 then
          setCursorPos(selectX + 1, selectY)
        elseif p1 == 208 then
          setCursorPos(selectX, selectY + 1)
        elseif p1 == 28 then
          placed = checkFit(i)
        elseif p1 == 29 or p1 == 157 then
          if dir == 0 then
                        dir = 1
          else
         dir = 0
          end
                end
           end
         end
  end
end

function startMonitor()
  for i=1,#rs.getSides() do
        if peripheral.isPresent(rs.getSides()[i]) and peripheral.getType(rs.getSides()[i]) == "monitor" then
          monSide = rs.getSides()[i]
          monitor = peripheral.wrap( monSide )
          return
        end
  end
  monSide = "none"
end

function startModem()
  local side
  for i=1,#rs.getSides() do
        if peripheral.isPresent(rs.getSides()[i]) and peripheral.getType(rs.getSides()[i]) == "modem" then
          side = rs.getSides()[i]
          rednet.open(side)
          return 1
        end
  end
  return 0
end

function hostWait()
  clearScreen()
  drawAt(1,1,"Waiting on "..opponentName.." to place ships...")
  drawArt()
  while true do
        local event, id, message = os.pullEvent()
        if event == "rednet_message" then
          if id == sendID then
                rednet.send(sendID,"!")
                return
          end
        end
  end
end

function clientWait()
  os.startTimer(1)
  while true do
        clearScreen()
        drawAt(1,1,"Waiting on "..opponentName.."to place ships...")
        drawArt()
        rednet.send(sendID,"!")
        local event, id, message = os.pullEvent()
        if event == "rednet_message" then
          if id == sendID then
                return
          end
        elseif event == "timer" then
          os.startTimer(1)
        end
  end
end

function sendShips()
  clearScreen()
  drawAt(1,1,"Exchanging Data...")
  for i = 1, #myShips do
        rednet.send(sendID,tostring(myShips[i][1]))
        rednet.send(sendID,tostring(myShips[i][2]))
        rednet.send(sendID,tostring(myShips[i][4]))
  end
end

function getShips()
  clearScreen()
  for i = 1, #myShips do
        for a = 1, 3 do
          bool = false
          while bool == false do
                id, message = rednet.receive()
                if id == sendID then
          if a == 3 then --4 is direction, which we want to exchange, not length (3)
         a = 4
          end
                  opponentShips[i][a] = tonumber(message)
          bool = true
                end
          end
        end
  end
end

function hostLobby()
  clearScreen()
  if startModem() == 0 then
        drawAt(1,1,"<ERROR> No Modem Detected")
        sleep(1)
        return false
  end
  drawArt()
  drawAt(1,1,"Type in your name: ")
  myName = io.read()
  clearScreen()
  drawAt(1,1,"Battleship - Host Lobby:")
  drawAt(1,2,"--------------------------")
  drawAt(1,3,"[Name: "..myName.. "  Computer ID: "..os.getComputerID().."]")
  drawAt(1,4,"Waiting for another player to join...")
  drawAt(1,5,"<Press Enter to Exit>")
  drawArt()

  while true do
        local event, getid, message = os.pullEvent()
        if event == "rednet_message" then
          if message == "*Battleship*" then
                sendID = tonumber(getid)
                drawAt(1,4,"Successfully Connected to #"..tostring(getid))
        rednet.send(getid,myName)
        
        while true do
          getid2, message = rednet.receive()
          if getid2 == getid then
         opponentName = message
                        return true
          end
        end
          end
        elseif event == "key" then
          if getid == 28 then
                return false
          end
        end
  end
end

function clientLobby()
  local connectID = -1
  clearScreen()
  if startModem() == 0 then
        drawAt(1,1,"<ERROR> No Modem Detected")
        sleep(1)
        return false
  end
  drawArt()
  drawAt(1,1,"Type in your name: ")
  myName = io.read()
  clearScreen()
  drawArt()
  drawAt(1,1,"Type in Computer # to connect to: ")
  connectID = -1
  while connectID < 0 do
        connectID = tonumber(io.read())
  end
  sendID = tonumber(connectID)
  clearScreen()
  drawAt(1,1,"Battleship - Client Lobby:")
  drawAt(1,2,"--------------------------")
  drawAt(1,3,"[Name: "..myName.. "  Computer ID: "..os.getComputerID().."]")
  drawAt(1,4,"Attemping to Connect to #"..connectID)
  drawAt(1,5,"<Press Enter to Exit>")
  drawArt()
  rednet.send(connectID,"*Battleship*")

  while true do
        local event, getid, message = os.pullEvent()
        if event == "rednet_message" and getid == connectID then
                opponentName = message
                drawAt(1,4,"Successfully Connected to #"..tostring(getid))
        rednet.send(connectID,myName)
                return true
        elseif event == "key" then
          if getid == 28 then
                return false
          end
        end
  end
end

--Handles all of the menu events
function menuEvents()
        event, p1 = os.pullEvent()
        if event == "key" then
          if p1 == 200 then
          menuSelect = menuSelect - 1
          if menuSelect < 1 then
                menuSelect = 4
          end
          elseif p1 == 208 then
         menuSelect = menuSelect + 1
         if menuSelect > 4 then
           menuSelect = 1
           end
                elseif p1 == 28 then
           if menuSelect == 1 then
                 if hostLobby() == true then
                   host = true
                   selectShips()
                   hostWait()
                   resetShips()
                   sendShips()
                   getShips()
                   game()
                 end
           elseif menuSelect == 2 then
                 if clientLobby() == true then
                   host = false
                   selectShips()
                   clientWait()
                   resetShips()
                   getShips()
                   sendShips()
                   game()
                 end
                  elseif menuSelect == 3 then
                 help()
                  elseif menuSelect == 4 then
                 --os.reboot()
                        clearScreen()
                        --error() quits the program
                        error()
           end
           end
        end
end

--The help menu
function help()
  clearScreen()
  drawAt(1,1,"Battleship - Help:")
  drawAt(1,2,"--------------------------")
  drawAt(1,3,"Each player places 5 ships on a 10x10 grid.")
  drawAt(1,4,"Players take turns firing on the grid, hoping to")
  drawAt(1,5,"  sink their opponent's ships.")
  drawAt(1,6,"The first player to sink all 5 of their opponent's")
  drawAt(1,7,"  ships wins!")
  drawAt(1,8,"Use Arrow Keys to move, and Enter to Fire.")
  drawAt(1,9,"You can press 'Backspace' to quit during a game.")
  drawAt(1,11,"<Press Enter to Exit Help>")
  while true do
        event, key = os.pullEvent()
        if event == "key" then
          if key == 28 then
         return
          end
        end
  end
end

function drawMenu()
  clearScreen()
  drawAt(1,1,"Battleship: ComputerCraft Edition")
  drawAt(1,2,"--------------------------")
  for i = 1, #menuOptions do
        drawAt(2,i + 2,"*")
        drawAt(4,i + 2,menuOptions[i])
  end
  drawCursor(1,3,2 + menuSelect)
  drawArt()
end

--Main Menu
function menu()
  menuSelect = 1
  while true do
        drawMenu()
        menuEvents()
  end
end


--Main Function
function main()
  menu()
end

--Run the program
main()
--proxy updater:
github_update()
