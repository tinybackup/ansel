# Ansel

A simple and fast vips image processing library for Gleam!

[![Package Version](https://img.shields.io/hexpm/v/ansel)](https://hex.pm/packages/ansel)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ansel/)

This library uses the [snag package](https://hexdocs.pm/snag/index.html) for error handling because vix errors are plentiful, come back as strings, and have not been enumerated. Install it as well to work with the error messages. 

The great vips library is used as the image processing backend, via the fantastic Elixir Vix package. Elixir must be installed to compile this package. The pre-compiled vips binary that comes with Vix supports the most common image formats, but a custom built vips binary can be provided to support even more. See more details about this below.


```sh
gleam add ansel
```

## Resizing Images

```gleam
import ansel
import ansel/image
import gleam/result
import snag

pub fn main() {
  let assert Ok(img) = image.read("input.jpeg")

  image.round(img, by: 20.0)
  |> result.try(image.border(_, with: color.GleamLucy, thickness: 6))
  |> result.try(image.scale_width(_, to: 600))
  |> result.try(
    image.write(_, "output", ansel.JPEG(quality: 60, keep_metadata: False)),
  )
  |> snag.context("Failed processing input.jpeg")
}
// -> output.jpeg written to disk as a smaller, rounded, bordered version of the
//    original image
```

## Extracting From and Layering Images

```gleam
import ansel
import ansel/image
import ansel/bounding_box
import gleam/result
import snag

pub fn main() {
  let assert Ok(img1) = image.read("input1.heic")
  let assert Ok(img2) = image.read("input2.png")

  let assert Ok(bounds) = bounding_box.ltwh(800, 800, 500, 500)

  image.extract_area(img1, at: bounds)
  |> result.try(
    image.composite_over(base: img2, with: _, at_left: 400, at_top: 300),
  )
  |> result.try(
    image.write(_, "output", ansel.PNG),
  )
  |> snag.context("Failed processing inputs")
}
// -> output.png written to disk with a 500x500 pixel area from input1 layered
//    on top of input2 starting at the coordinate 400, 300
```

Further documentation can be found at <https://hexdocs.pm/ansel>.

## Additional Image Format Support
Vix comes with a pre-compiled vips binary, but a custom built vips binary can be provided on the host system to use with this package as well by setting the host system environment variable `VIX_COMPILATION_MODE` to `PLATFORM_PROVIDED_LIBVIPS` before compiling. Vips can be configured to work with many different image formats, but they are dependent on the libraries you build it with. For this reason, you may want to install your own image encoders and decoders to support the formats you need, then bring your own vips binary to use with this package. More information can be found in the [vips documentation](https://github.com/libvips/libvips?tab=readme-ov-file#optional-dependencies).

eg. on Linux, to bring your own heif encoders / decoders: 
```
sudo apt install libvips-tools
sudo apt install libvips-dev
sudo apt install libheif
export VIX_COMPILATION_MODE=PLATFORM_PROVIDED_LIBVIPS
gleam clean
gleam run
```

## Development

```sh
gleam test  # Run the tests
```
