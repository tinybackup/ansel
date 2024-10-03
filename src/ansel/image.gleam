import ansel
import ansel/color
import ansel/fixed_bounding_box
import gleam/int
import gleam/result
import snag

fn image_format_to_string(format: ansel.ImageFormat) -> String {
  case format {
    ansel.JPEG(quality) -> ".jpeg[Q=" <> int.to_string(quality) <> "]"
    ansel.JPEG2000 -> ".jp2"
    ansel.JPEGXL -> ".jxl"
    ansel.PNG -> ".png"
    ansel.WebP(quality) -> ".webp[Q=" <> int.to_string(quality) <> "]"
    ansel.AVIF(quality) -> ".avif[Q=" <> int.to_string(quality) <> "]"
    ansel.TIFF -> ".tiff"
    ansel.HEIC -> ".heic"
    ansel.FITS -> ".fits"
    ansel.Matlab -> ".mat"
    ansel.PDF -> ".pdf"
    ansel.SVG -> ".svg"
    ansel.HDR -> ".hdr"
    ansel.PPM -> ".ppm"
    ansel.CSV -> ".csv"
    ansel.GIF -> ".gif"
    ansel.Analyze -> ".analyze"
    ansel.NIfTI -> ".nii"
    ansel.DeepZoom -> ".dzi"
  }
}

pub fn fit_fixed_bounding_box(
  bounding_box: fixed_bounding_box.FixedBoundingBox,
  in image: ansel.Image,
) -> Result(fixed_bounding_box.FixedBoundingBox, Nil) {
  let width = get_width(image)
  let height = get_height(image)

  let #(left, top, right, bottom) =
    fixed_bounding_box.to_ltrb_tuple(bounding_box)

  case left < width, top < height {
    True, True ->
      Ok(fixed_bounding_box.LTRB(
        left: left,
        top: top,
        right: int.min(right, width),
        bottom: int.min(bottom, height),
      ))

    _, _ -> Error(Nil)
  }
}

pub fn from_bit_array(bin: BitArray) -> Result(ansel.Image, snag.Snag) {
  from_bit_array_ffi(bin)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from bit array")
}

@external(erlang, "Elixir.Vix.Vips.Image", "new_from_buffer")
fn from_bit_array_ffi(bin: BitArray) -> Result(ansel.Image, String)

pub fn to_bit_array(img: ansel.Image, format: ansel.ImageFormat) -> BitArray {
  to_bit_array_ffi(img, image_format_to_string(format))
}

@external(erlang, "Elixir.Ansel", "to_bit_array")
fn to_bit_array_ffi(img: ansel.Image, format: String) -> BitArray

pub fn new_image(
  width width: Int,
  height height: Int,
  color color: color.Color,
) -> Result(ansel.Image, snag.Snag) {
  new_image_ffi(width, height, color.to_bands(color))
  |> result.map_error(snag.new)
  |> snag.context("Failed to create new image")
}

@external(erlang, "Elixir.Ansel", "new_image")
fn new_image_ffi(
  width: Int,
  height: Int,
  color: List(Int),
) -> Result(ansel.Image, String)

pub fn extract_area(
  from image: ansel.Image,
  at bounding_box: fixed_bounding_box.FixedBoundingBox,
) -> Result(ansel.Image, snag.Snag) {
  let #(left, top, width, height) =
    fixed_bounding_box.to_ltwh_tuple(bounding_box)

  extract_area_ffi(image, left, top, width, height)
  |> result.map_error(snag.new)
  |> snag.context("Failed to extract area from image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "extract_area")
fn extract_area_ffi(
  image: ansel.Image,
  x: Int,
  y: Int,
  w: Int,
  h: Int,
) -> Result(ansel.Image, String)

pub fn composite_over(
  base: ansel.Image,
  with overlay: ansel.Image,
  at_left l: Int,
  at_top t: Int,
) -> Result(ansel.Image, snag.Snag) {
  composite_over_ffi(base, overlay, l, t)
  |> result.map_error(snag.new)
  |> snag.context("Failed to composite overlay image over base image")
}

@external(erlang, "Elixir.Ansel", "composite_over")
fn composite_over_ffi(
  base: ansel.Image,
  overlay: ansel.Image,
  x: Int,
  y: Int,
) -> Result(ansel.Image, String)

pub fn fill(
  image: ansel.Image,
  in bounding_box: fixed_bounding_box.FixedBoundingBox,
  with color: color.Color,
) {
  let #(left, top, width, height) =
    fixed_bounding_box.to_ltwh_tuple(bounding_box)

  new_image(width:, height:, color:)
  |> result.try(composite_over(image, _, at_left: left, at_top: top))
}

@external(erlang, "Elixir.Vix.Vips.Image", "width")
pub fn get_width(image: ansel.Image) -> Int

@external(erlang, "Elixir.Vix.Vips.Image", "height")
pub fn get_height(image: ansel.Image) -> Int

pub fn resize_width_to(
  img: ansel.Image,
  resolution width: Int,
) -> Result(ansel.Image, snag.Snag) {
  resize_by(img, scale: int.to_float(width) /. int.to_float(get_width(img)))
}

pub fn resize_height_to(
  img: ansel.Image,
  resolution height: Int,
) -> Result(ansel.Image, snag.Snag) {
  resize_by(img, scale: int.to_float(height) /. int.to_float(get_height(img)))
}

pub fn resize_by(
  img: ansel.Image,
  scale scale: Float,
) -> Result(ansel.Image, snag.Snag) {
  resize_ffi(img, scale)
  |> result.map_error(snag.new)
  |> snag.context("Failed to resize image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "resize")
fn resize_ffi(img: ansel.Image, scale: Float) -> Result(ansel.Image, String)

pub fn write(
  img: ansel.Image,
  to path: String,
  in format: ansel.ImageFormat,
) -> Result(Nil, snag.Snag) {
  write_ffi(img, path <> image_format_to_string(format))
  |> result.map_error(snag.new)
  |> snag.context("Failed to write image to file")
}

@external(erlang, "Elixir.Ansel", "write_to_file")
fn write_ffi(img: ansel.Image, to path: String) -> Result(Nil, String)

pub fn read(from path: String) -> Result(ansel.Image, snag.Snag) {
  read_ffi(path)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from file")
}

@external(erlang, "Elixir.Ansel", "read")
fn read_ffi(from path: String) -> Result(ansel.Image, String)

pub fn create_thumbnail(
  from path: String,
  width width: Int,
) -> Result(ansel.Image, snag.Snag) {
  create_thumbnail_ffi(path, width)
  |> result.map_error(snag.new)
  |> snag.context("Failed to create thumbnail from file")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "thumbnail")
fn create_thumbnail_ffi(path: String, width: Int) -> Result(ansel.Image, String)
