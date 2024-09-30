import gleam/io
import gleam/result
import simplifile
import snag

pub fn main() {
  io.println("Hello from ansel!")

  let assert Ok(base) =
    simplifile.read_bits("test.jpg")
    |> result.unwrap(<<>>)
    |> from_bit_array

  let assert Ok(overlay) =
    simplifile.read_bits("ss.png")
    |> result.unwrap(<<>>)
    |> from_bit_array

  let _ =
    composite_over(base, overlay, 1, 1)
    |> result.map(write(_, "out.jpg"))

  base
  |> extract_area(LTWH(left: 100, top: 100, width: 400, height: 400))
  |> result.map(write(_, "out2.jpg"))
  |> io.debug
}

pub type BoundingBox {
  LTWH(left: Int, top: Int, width: Int, height: Int)
  LTRB(left: Int, top: Int, right: Int, bottom: Int)
  X1Y1X2Y2(x1: Int, y1: Int, x2: Int, y2: Int)
}

pub type Image

pub fn from_bit_array(bin: BitArray) -> Result(Image, snag.Snag) {
  from_bit_array_ffi(bin)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from bit array")
}

pub fn write(img: Image, to path: String) -> Result(Nil, snag.Snag) {
  write_ffi(img, path)
  |> result.map_error(snag.new)
  |> snag.context("Failed to write image to file")
}

pub fn extract_area(
  from image: Image,
  at bounding_box: BoundingBox,
) -> Result(Image, snag.Snag) {
  case bounding_box {
    LTWH(left, top, width, height) ->
      extract_area_ffi(image, left, top, width, height)
    LTRB(left, top, right, bottom) ->
      extract_area_ffi(image, left, top, right - left, bottom - top)
    X1Y1X2Y2(x1, y1, x2, y2) ->
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
