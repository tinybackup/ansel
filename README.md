# ansel

[![Package Version](https://img.shields.io/hexpm/v/ansel)](https://hex.pm/packages/ansel)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ansel/)

```sh
gleam add ansel@1
```

## Resizing Images

```gleam
import ansel
import ansel/image
import gleam/result

pub fn main() {
  let assert Ok(img) = image.read("input.jpeg")

  image.resize_by(img, scale: 0.5)
  |> result.try(image.border(_, with: color.GleamLucy, thickness: 6))
  |> result.try(
    image.write(_, "output", ansel.JPEG(quality: 60, keep_metadata: False)),
  )
}
// -> output.jpeg written to disk as a smaller. bordered version of the
//    original image
```

## Extracting From and Layering Images

```gleam
import ansel
import ansel/image
import ansel/bounding_box
import gleam/result

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
}
// -> output.png written to disk with a 500x500 pixel area from input1 layered
//    on top of input2 starting at the coordinate 400, 300
```

Further documentation can be found at <https://hexdocs.pm/ansel>.

## Development

```sh
gleam test  # Run the tests
```
