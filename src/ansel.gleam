import ansel/bounding_box
import ansel/color
import gleam/io
import gleam/result
import simplifile
import snag

pub fn main() {
  io.println("Hello from ansel!")

  // let assert Ok(base) =
  //   simplifile.read_bits("test.jpg")
  //   |> result.unwrap(<<>>)
  //   |> from_bit_array

  // let assert Ok(overlay) =
  //   simplifile.read_bits("ss.png")
  //   |> result.unwrap(<<>>)
  //   |> from_bit_array

  // let _ =
  //   composite_over(base, overlay, 1, 1)
  //   |> result.map(write(_, "out.jpg"))

  // base
  // |> extract_area(LTWH(left: 100, top: 100, width: 400, height: 400))
  // |> result.map(write(_, "out2.jpg"))
  // |> io.debug

  new_image(width: 100, height: 100, color: color.Grey)
  |> result.map(write(_, "out2.jpg"))
}

pub type Image

pub fn from_bit_array(bin: BitArray) -> Result(Image, snag.Snag) {
  from_bit_array_ffi(bin)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from bit array")
}

pub fn new_image(
  width width: Int,
  height height: Int,
  color color: color.Color,
) -> Result(Image, snag.Snag) {
  new_image_ffi(width, height, color.to_bands(color))
  |> result.map_error(snag.new)
  |> snag.context("Failed to create new image")
}

@external(erlang, "Elixir.Ansel", "new_image")
fn new_image_ffi(
  width: Int,
  height: Int,
  color: List(Int),
) -> Result(Image, String)

pub fn extract_area(
  from image: Image,
  at bounding_box: bounding_box.BoundingBox,
) -> Result(Image, snag.Snag) {
  case bounding_box {
    bounding_box.LTWH(left, top, width, height) ->
      extract_area_ffi(image, left, top, width, height)
    bounding_box.LTRB(left, top, right, bottom) ->
      extract_area_ffi(image, left, top, right - left, bottom - top)
    bounding_box.X1Y1X2Y2(x1, y1, x2, y2) ->
      extract_area_ffi(image, x1, y1, x2 - x1, y2 - y1)
  }
  |> result.map_error(snag.new)
  |> snag.context("Failed to extract area from image")
}

pub fn composite_over(
  base: Image,
  with overlay: Image,
  at_left_position l: Int,
  at_top_position t: Int,
) -> Result(Image, snag.Snag) {
  composite_over_ffi(base, overlay, l, t)
  |> result.map_error(snag.new)
  |> snag.context("Failed to composite overlay image over base image")
}

pub fn write(img: Image, to path: String) -> Result(Nil, snag.Snag) {
  write_ffi(img, path)
  |> result.map_error(snag.new)
  |> snag.context("Failed to write image to file")
}

@external(erlang, "Elixir.Ansel", "from_bit_array")
fn from_bit_array_ffi(bin: BitArray) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Operation", "extract_area")
fn extract_area_ffi(
  image: Image,
  x: Int,
  y: Int,
  w: Int,
  h: Int,
) -> Result(Image, String)

@external(erlang, "Elixir.Ansel", "composite_over")
fn composite_over_ffi(
  base: Image,
  overlay: Image,
  x: Int,
  y: Int,
) -> Result(Image, String)

@external(erlang, "Elixir.Ansel", "write_to_file")
fn write_ffi(img: Image, to path: String) -> Result(Nil, String)
