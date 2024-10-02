import ansel/bounding_box
import ansel/color
import gleam/int
import gleam/result
import snag

pub type ImageFormat {
  JPEG(quality: Int)
  JPEG2000
  JPEGXL
  PNG
  WebP(quality: Int)
  AVIF(quality: Int)
  TIFF
  HEIC
  FITS
  Matlab
  PDF
  SVG
  HDR
  PPM
  CSV
  GIF
  Analyze
  NIfTI
  DeepZoom
}

fn image_format_to_string(format: ImageFormat) -> String {
  case format {
    JPEG(quality) -> ".jpeg[Q=" <> int.to_string(quality) <> "]"
    JPEG2000 -> ".jp2"
    JPEGXL -> ".jxl"
    PNG -> ".png"
    WebP(quality) -> ".webp[Q=" <> int.to_string(quality) <> "]"
    AVIF(quality) -> ".avif[Q=" <> int.to_string(quality) <> "]"
    TIFF -> ".tiff"
    HEIC -> ".heic"
    FITS -> ".fits"
    Matlab -> ".mat"
    PDF -> ".pdf"
    SVG -> ".svg"
    HDR -> ".hdr"
    PPM -> ".ppm"
    CSV -> ".csv"
    GIF -> ".gif"
    Analyze -> ".analyze"
    NIfTI -> ".nii"
    DeepZoom -> ".dzi"
  }
}

pub type Image

pub fn from_bit_array(bin: BitArray) -> Result(Image, snag.Snag) {
  from_bit_array_ffi(bin)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from bit array")
}

@external(erlang, "Elixir.Vix.Vips.Image", "new_from_buffer")
fn from_bit_array_ffi(bin: BitArray) -> Result(Image, String)

pub fn to_bit_array(img: Image, format: ImageFormat) -> BitArray {
  to_bit_array_ffi(img, image_format_to_string(format))
}

@external(erlang, "Elixir.Ansel", "to_bit_array")
fn to_bit_array_ffi(img: Image, format: String) -> BitArray

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
  let #(left, top, width, height) = bounding_box.to_ltwh_tuple(bounding_box)

  extract_area_ffi(image, left, top, width, height)
  |> result.map_error(snag.new)
  |> snag.context("Failed to extract area from image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "extract_area")
fn extract_area_ffi(
  image: Image,
  x: Int,
  y: Int,
  w: Int,
  h: Int,
) -> Result(Image, String)

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

@external(erlang, "Elixir.Ansel", "composite_over")
fn composite_over_ffi(
  base: Image,
  overlay: Image,
  x: Int,
  y: Int,
) -> Result(Image, String)

@external(erlang, "Elixir.Vix.Vips.Image", "width")
pub fn get_width(image: Image) -> Int

@external(erlang, "Elixir.Vix.Vips.Image", "height")
pub fn get_height(image: Image) -> Int

pub fn resize_width_to(img: Image, res width: Int) -> Result(Image, snag.Snag) {
  resize_by(img, scale: int.to_float(width) /. int.to_float(get_width(img)))
}

pub fn resize_height_to(img: Image, res height: Int) -> Result(Image, snag.Snag) {
  resize_by(img, scale: int.to_float(height) /. int.to_float(get_height(img)))
}

pub fn resize_by(img: Image, scale scale: Float) -> Result(Image, snag.Snag) {
  resize_ffi(img, scale)
  |> result.map_error(snag.new)
  |> snag.context("Failed to resize image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "resize")
fn resize_ffi(img: Image, scale: Float) -> Result(Image, String)

pub fn write(
  img: Image,
  to path: String,
  in format: ImageFormat,
) -> Result(Nil, snag.Snag) {
  write_ffi(img, path <> image_format_to_string(format))
  |> result.map_error(snag.new)
  |> snag.context("Failed to write image to file")
}

@external(erlang, "Elixir.Ansel", "write_to_file")
fn write_ffi(img: Image, to path: String) -> Result(Nil, String)

pub fn read(from path: String) -> Result(Image, snag.Snag) {
  read_ffi(path)
  |> result.map_error(snag.new)
  |> snag.context("Failed to read image from file")
}

@external(erlang, "Elixir.Ansel", "read")
fn read_ffi(from path: String) -> Result(Image, String)

pub fn create_thumbnail(
  from path: String,
  width width: Int,
) -> Result(Image, snag.Snag) {
  create_thumbnail_ffi(path, width)
  |> result.map_error(snag.new)
  |> snag.context("Failed to create thumbnail from file")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "thumbnail")
fn create_thumbnail_ffi(path: String, width: Int) -> Result(Image, String)

pub fn main() {
}
