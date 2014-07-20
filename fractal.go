package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"math"
	"math/cmplx"
  "runtime"
	"os"
)

func find_color(x int, y int, width int, height int, max_iter int, julia_seed complex128, img *image.RGBA) {
	minRe := -0.7
	maxRe := -0.71
	minIm := -0.719
	maxIm := minIm + (maxRe-minRe)*float64(height)/float64(width)
	re_factor := (maxRe - minRe) / float64(width-1)
	im_factor := (maxIm - minIm) / float64(height-1)
	c_re := minRe + float64(x)*re_factor
	c_im := maxIm - float64(y)*im_factor

	z := complex(c_re, c_im)
	c := julia_seed

	var iter int
	for i := 0; i <= max_iter && cmplx.Abs(z) < 4; i++ {
		iter = i
		zloc := cmplx.Pow(z, 2) + c
		if zloc == z {
			iter = max_iter
			break
		}
		z = zloc
	}

	var pixel color.RGBA
	iter_f := float64(iter)
	max_iter_f := float64(max_iter)
	if iter_f <= max_iter_f/3-1 {
		pixel = color.RGBA{
			0,
			uint8(math.Ceil(128 * (iter_f / max_iter_f))),
			uint8(math.Ceil(255 * (iter_f / max_iter_f))),
			255,
		}
	} else if iter_f < max_iter_f/3*2-1 {
		pixel = color.RGBA{
			uint8(math.Ceil(255 * (iter_f / max_iter_f))),
			uint8(math.Ceil(128 - 128*(iter_f/max_iter_f))),
			uint8(math.Ceil(255 - 255*(iter_f/max_iter_f))),
			255,
		}
	} else if iter_f < max_iter_f {
		pixel = color.RGBA{
			uint8(math.Ceil(76 * (iter_f / max_iter_f))),
			0,
			uint8(math.Ceil(153 * (iter_f / max_iter_f))),
			255,
		}
	} else {
		pixel = color.RGBA{0, 0, 0, 255}
	}
	img.Set(x, y, pixel)
}

func main() {
  runtime.GOMAXPROCS(runtime.NumCPU())
	w := flag.Int("width", 400, "Width of generated image in pixels")
	h := flag.Int("height", 400, "Height of generated image in pixels")
	m := flag.Int("iter", 100, "Maximum number of iterations per pixel")
	out := flag.String("output", "go_fractal", "Name fo file to output to")
	flag.Parse()
	width := *w
	height := *h
	max_iter := *m

	seed := complex(-0.156844471694257101941, -0.649707745759247905171)
	img := image.NewRGBA(image.Rect(0, 0, width, height))

	fmt.Println("Starting render...")
	for i := 0; i < width; i++ {
		if i%100 == 0 {
			fmt.Printf("\rProgress: %d", i)
		}
		for j := 0; j < height; j++ {
			find_color(i, j, width, height, max_iter, seed, img)
		}
	}

	output, err := os.Create(*out + ".png")
	defer output.Close()
	if err != nil {
		panic(err)
	}
	png.Encode(output, img)
	fmt.Println()
	fmt.Println("Done!")
}
