local math = require('math')
local complex = require('complex')
local imlib = require('imlib2')

function find_color(x, y, width, height, max_iter)
  --coordinate translation variables
  local minRe = -2.0
  local maxRe = 1.0
  local minIm = -1.2
  local maxIm = minIm+(maxRe-minRe)*height/width
  local re_factor = (maxRe-minRe)/(width-1)
  local im_factor = (maxIm-minIm)/(height-1)
  local c_re = minRe + x * re_factor
  local c_im = maxIm - y * im_factor

  local z, c, iter
  z = complex.new(c_re, c_im)
  c = z
  for i = 0, max_iter do
    iter = i
    if complex.abs(z) > 4 then
      break
    end
    z = z^2 + c
  end

  --Transition from black to red for low counts, then red to white for high counts
  color = math.ceil(255*(iter/max_iter))
  if iter <= max_iter/2-1 then
    r = color
    g, b = 0, 0
  elseif iter < max_iter then
    r = 255
    g, b = color, color
  else
    r, g, b = 0, 0, 0
  end

  return imlib.color.new(r, g, b)
end

function make_img(width, height, max_iter)
  imlib.set_anti_alias(false)
  local data = imlib.image.new(width, height)
  print("Rendering image...")
  for i = 0, width-1 do
    for j = 0, height-1 do
      color = find_color(i, j, width, height, max_iter)
      data:draw_pixel(i, j, color)
    end
  end
  return data
end

function main()
  img = make_img(2000, 2000, 50)
  img:save("fractal_noaa.png")
end

main()
