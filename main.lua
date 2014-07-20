local io = require('io')
local math = require('math')
local complex = require('complex')
local imlib = require('imlib2')

function find_color(x, y, width, height, max_iter, julia_seed)
  --coordinate translation variables
  local minRe = -0.7
  local maxRe = -0.71
  local minIm = -0.719
  local maxIm = minIm+(maxRe-minRe)*height/width
  local re_factor = (maxRe-minRe)/(width-1)
  local im_factor = (maxIm-minIm)/(height-1)
  local c_re = minRe + x * re_factor
  local c_im = maxIm - y * im_factor

  local z, c, iter
  z = complex.new(c_re, c_im)
  if julia_seed ~= nil then
    c = julia_seed
  else
    c = z
  end 

  i = 0
  while i <= max_iter and complex.abs(z) < 4 do
    iter = i
    zloc = z^2 + c
    if zloc == z then
      iter = max_iter
      break
    end
    z = zloc
    i = i+1
  end

  --Transition from black to red for low counts, then red to white for high counts
  
  if iter <= max_iter/3-1 then
    r = 0
    g = math.ceil(128*(iter/max_iter))
    b = math.ceil(255*(iter/max_iter))
  elseif iter < max_iter/3*2-1 then
    r = math.ceil(255*(iter/max_iter))
    g = 128-math.ceil(128*(iter/max_iter))
    b = 255-math.ceil(255*(iter/max_iter))
  elseif iter < max_iter then
    r = math.ceil(76*(iter/max_iter))
    g = 0
    b = math.ceil(153*(iter/max_iter))
  else
    r, g, b = 0, 0, 0
  end

  return imlib.color.new(r, g, b)
end

function make_img(width, height, max_iter, seed)
  imlib.set_anti_alias(false)
  local data = imlib.image.new(width, height)
  print("Rendering image...")
  for i = 0, width-1 do
    if i%100 == 0 then
      io.write("\rColumn: ", i)
    end
    for j = 0, height-1 do
      color = find_color(i, j, width, height, max_iter, seed)
      data:draw_pixel(i, j, color)
    end
  end
  return data
end

function main()
  img = make_img(1000, 1000, 150, complex.new(-0.156844471694257101941, -0.649707745759247905171))
  --img = make_img(1000, 1000, 200)
  img:save("fractal.png")
end

main()
