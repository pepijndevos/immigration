local size = 64
local score = {['r'] = 2, ['b'] = 3}
local hcells = math.floor(director.displayWidth / size) - 1
local vcells = math.floor(director.displayHeight / size) - 1

function empty()
  local world = {}
  for x = 0, hcells do
    world[x] = {}
  end
  return world
end

function max(t)
  local M,I=0,0
  for k,v in pairs(t) do
    if v>M then M,I=v,k end
  end
  return I
end

function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end

    return sum
end

function count_life(world, x, y)
  local count = {};
  for dx = -1, 1 do
    for dy = -1, 1 do
      if (dx ~= 0 or dy ~= 0) and (world[x+dx] or {})[y+dy] ~= nil then
        count[world[x+dx][y+dy]] = (count[world[x+dx][y+dy]] or 0) + 1
      end
    end
  end
  return count
end
 
function evolve(world)
  local new_world = empty()
 
  for x = 0, hcells do
    for y = 0, vcells do
      local count = count_life(world, x, y)
      local total = sum(count)
      local species = world[x][y]

      --print(x, y, species, total, max(count))

      -- Any live cell with fewer than two live neighbours dies, as if caused by under-population.
      -- Any live cell with more than three live neighbours dies, as if by overcrowding.
      if species ~= nil and (total < 2 or total > 3) then
        new_world[x][y] = nil
        score[species] = score[species] - 1
      end
      -- Any live cell with two or three live neighbours lives on to the next generation.
      if species ~= nil and (total == 2 or total == 3) then
        new_world[x][y] = species
      end
      -- Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
      if species == nil and total == 3 then
        local new_species = max(count)
        new_world[x][y] = new_species
        score[new_species] = score[new_species] + 1
      end
    end
  end
 
  return new_world
end

world = empty()
circles = empty()

function cycleColor(event)
  --if event.phase == "began" then
  if true then
    print("touched")
    circle = event.target
    print(circle.gx, circle.gy)
    if world[circle.gx][circle.gy] == "r" then
      world[circle.gx][circle.gy] = "b"
      circle.color = color.blue
    elseif world[circle.gx][circle.gy] == "b" then
      world[circle.gx][circle.gy] = nil
      circle.color = color.white
    else
      world[circle.gx][circle.gy] = "r"
      circle.color = color.red
    end
  end
end

for x = 0, hcells do
  for y = 0, vcells do
    local circle = director:createCircle(x*size, y*size, size/2)
    circle.gx = x
    circle.gy = y
    circle:addEventListener("touch", cycleColor)
    circles[x][y] = circle
  end
end

function draw()
  for x = 0, hcells do
    for y = 0, vcells do
    if world[x][y] == "r" then
      circles[x][y].color = color.red
    elseif world[x][y] == "b" then
      circles[x][y].color = color.blue
    else
      circles[x][y].color = color.white
    end
    end
  end
end

function life()
  world = evolve(world)
  draw()
end

system:addTimer(life, 1)
