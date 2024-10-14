import ansel
import ansel/bounding_box
import ansel/color
import gleam/bool
import gleam/int
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import snag

fn image_format_to_string(format: ansel.ImageFormat) -> String {
  case format {
    ansel.JPEG(quality:, keep_metadata:) ->
      ".jpeg" <> format_common_options(quality, keep_metadata)
    ansel.JPEG2000(quality:, keep_metadata:) ->
      ".jp2" <> format_common_options(quality, keep_metadata)
    ansel.JPEGXL(quality:, keep_metadata:) ->
      ".jxl" <> format_common_options(quality, keep_metadata)
    ansel.PNG -> ".png"
    ansel.WebP(quality:, keep_metadata:) ->
      ".webp" <> format_common_options(quality, keep_metadata)
    ansel.AVIF(quality:, keep_metadata:) ->
      ".avif" <> format_common_options(quality, keep_metadata)
    ansel.TIFF(quality:, keep_metadata:) ->
      ".tiff" <> format_common_options(quality, keep_metadata)
    ansel.HEIC(quality:, keep_metadata:) ->
      ".heic" <> format_common_options(quality, keep_metadata)
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
    ansel.Custom(format:) -> format
  }
}

fn format_common_options(quality, keep_metadata) {
  "[Q="
  <> int.to_string(quality)
  <> ",strip="
  <> bool.to_string(!keep_metadata) |> string.lowercase
  <> "]"
}

/// Fits a fixed bounding box to an image by dropping any pixels outside the
/// dimensions of the image.
/// 
/// ## Example
/// 
/// ```gleam
/// let assert Ok(bb) = bounding_box.ltwh(4, 2, 40, 30)
/// let assert Ok(img) = image.new(6, 7, color.GleamLucy)
/// image.fit_bounding_box(bb, in: img)
/// // -> bounding_box.ltwh(left: 4, top: 2, width: 2, height: 5)
/// ```
pub fn fit_bounding_box(
  bounding_box: bounding_box.BoundingBox,
  in image: ansel.Image,
) -> Result(bounding_box.BoundingBox, snag.Snag) {
  let width = get_width(image)
  let height = get_height(image)

  let #(left, top, right, bottom) = bounding_box.to_ltrb_tuple(bounding_box)

  case left < width, top < height {
    True, True ->
      bounding_box.ltrb(
        left: left,
        top: top,
        right: int.min(right, width),
        bottom: int.min(bottom, height),
      )

    _, _ ->
      snag.error("Passed bounding box is completely outside the image to fit")
  }
}

/// Reads a vips image from a bit array, assuming it is in a valid image.
/// 
/// ## Example
/// ```gleam
/// simplifile.read_bits("input.jpeg")
/// |> result.try(image.from_bit_array)
/// // -> Ok(ansel.Image)
/// ```
pub fn from_bit_array(bin: BitArray) -> Result(ansel.Image, snag.Snag) {
  from_bit_array_ffi(bin)
  |> result.map_error(snag.new)
  |> snag.context("Unable to read image from bit array")
}

@external(erlang, "Elixir.Vix.Vips.Image", "new_from_buffer")
fn from_bit_array_ffi(bin: BitArray) -> Result(ansel.Image, String)

/// Saves a vips image to a bit array. Assumes your vips was built with the
/// correct encoder support for the format to save in.
/// 
/// ## Example
/// ```gleam
/// image.new(6, 6, color.GleamLucy)
/// |> result.map(to_bit_array(_, ansel.PNG))
/// |> result.try(simplifile.write_bits("output.png"))
/// ```
pub fn to_bit_array(img: ansel.Image, format: ansel.ImageFormat) -> BitArray {
  to_bit_array_ffi(img, image_format_to_string(format))
}

@external(erlang, "Elixir.Ansel", "to_bit_array")
fn to_bit_array_ffi(img: ansel.Image, format: String) -> BitArray

/// Creates a new image with the specified width, height, and color
/// 
/// ## Example
/// ```gleam
/// image.new(6, 6, color.Olive)
/// // -> Ok(ansel.Image)
/// ```
pub fn new(
  width width: Int,
  height height: Int,
  color color: color.Color,
) -> Result(ansel.Image, snag.Snag) {
  new_image_ffi(width, height, color.to_bands(color))
  |> result.map_error(snag.new)
  |> snag.context("Unable to create new image")
}

@external(erlang, "Elixir.Ansel", "new_image")
fn new_image_ffi(
  width: Int,
  height: Int,
  color: List(Int),
) -> Result(ansel.Image, String)

/// Extracts an area out of an image, resulting in a new image of the 
/// extracted area.
/// 
pub fn extract_area(
  from image: ansel.Image,
  at bounding_box: bounding_box.BoundingBox,
) -> Result(ansel.Image, snag.Snag) {
  let #(left, top, width, height) = bounding_box.to_ltwh_tuple(bounding_box)

  extract_area_ffi(image, left, top, width, height)
  |> result.map_error(snag.new)
  |> snag.context("Unable to extract area from image")
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
  |> snag.context("Unable to composite overlay image over base image")
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
  in bounding_box: bounding_box.BoundingBox,
  with color: color.Color,
) {
  let #(left, top, width, height) = bounding_box.to_ltwh_tuple(bounding_box)

  new(width:, height:, color:)
  |> result.try(composite_over(image, _, at_left: left, at_top: top))
}

pub fn outline(
  image: ansel.Image,
  area bounding_box: bounding_box.BoundingBox,
  with color: color.Color,
  thickness thickness: Int,
) {
  let #(left, top, width, height) = bounding_box.to_ltwh_tuple(bounding_box)

  let original_bb = bounding_box |> bounding_box.shrink(by: thickness)

  use outline <- result.try(new(width:, height:, color:))

  use filled <- result.try(composite_over(
    image,
    outline,
    at_left: left,
    at_top: top,
  ))

  case original_bb {
    Some(original_bb) -> {
      let #(original_left, original_top, _, _) =
        bounding_box.to_ltwh_tuple(original_bb)

      use original_area <- result.try(extract_area(image, at: original_bb))

      composite_over(
        filled,
        with: original_area,
        at_left: original_left,
        at_top: original_top,
      )
    }

    None -> Ok(filled)
  }
}

pub fn border(
  around image: ansel.Image,
  with color: color.Color,
  thickness thickness: Int,
) {
  let height = get_height(image)
  let width = get_width(image)

  use #(_, _, outline_width, outline_height) <- result.try(
    bounding_box.ltwh(left: 0, top: 0, width: width, height: height)
    |> result.map(bounding_box.expand(_, by: thickness))
    |> result.map(bounding_box.to_ltwh_tuple),
  )

  new(width: outline_width, height: outline_height, color:)
  |> result.try(composite_over(_, image, at_left: thickness, at_top: thickness))
}

/// Applies a gaussian blur to an image.
pub fn blur(
  image: ansel.Image,
  with sigma: Float,
) -> Result(ansel.Image, snag.Snag) {
  gaussblur_ffi(image, sigma)
  |> result.map_error(snag.new)
  |> snag.context("Unable to blur image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "gaussblur")
fn gaussblur_ffi(img: ansel.Image, sigma: Float) -> Result(ansel.Image, String)

pub fn rotate(
  image: ansel.Image,
  by degrees: Float,
) -> Result(ansel.Image, snag.Snag) {
  // Rotating by an exact degree of 90, 180, or 270 is a special operation
  // in Vix and is different than the generic rotate operation.
  case degrees {
    0.0 -> Ok(image)
    90.0 -> rotate90_ffi(image)
    180.0 -> rotate180_ffi(image)
    270.0 -> rotate270_ffi(image)
    _ -> rotate_ffi(image, degrees)
  }
  |> result.map_error(snag.new)
  |> snag.context("Unable to rotate image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "rotate")
fn rotate_ffi(img: ansel.Image, degrees: Float) -> Result(ansel.Image, String)

@external(erlang, "Elixir.Ansel", "rotate90")
fn rotate90_ffi(img: ansel.Image) -> Result(ansel.Image, String)

@external(erlang, "Elixir.Ansel", "rotate180")
fn rotate180_ffi(img: ansel.Image) -> Result(ansel.Image, String)

@external(erlang, "Elixir.Ansel", "rotate270")
fn rotate270_ffi(img: ansel.Image) -> Result(ansel.Image, String)

/// Implmentation heavily inspired by the great Image elixir library.
pub fn round(
  image: ansel.Image,
  by radius: Float,
) -> Result(ansel.Image, snag.Snag) {
  round_ffi(image, radius)
  |> result.map_error(snag.new)
  |> snag.context("Unable to round image")
}

@external(erlang, "Elixir.Ansel", "round")
fn round_ffi(img: ansel.Image, radius: Float) -> Result(ansel.Image, String)

@external(erlang, "Elixir.Vix.Vips.Image", "width")
pub fn get_width(image: ansel.Image) -> Int

@external(erlang, "Elixir.Vix.Vips.Image", "height")
pub fn get_height(image: ansel.Image) -> Int

pub fn to_bounding_box(image: ansel.Image) -> bounding_box.BoundingBox {
  bounding_box.unchecked_ltwh(
    left: 0,
    top: 0,
    width: get_width(image),
    height: get_height(image),
  )
}

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
  |> snag.context("Unable to resize image")
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
  |> snag.context("Unable to write image to file")
}

@external(erlang, "Elixir.Ansel", "write_to_file")
fn write_ffi(img: ansel.Image, to path: String) -> Result(Nil, String)

pub fn read(from path: String) -> Result(ansel.Image, snag.Snag) {
  read_ffi(path)
  |> result.map_error(snag.new)
  |> snag.context("Unable to read image from file")
}

@external(erlang, "Elixir.Ansel", "read")
fn read_ffi(from path: String) -> Result(ansel.Image, String)

pub fn create_thumbnail(
  from path: String,
  width width: Int,
) -> Result(ansel.Image, snag.Snag) {
  create_thumbnail_ffi(path, width)
  |> result.map_error(snag.new)
  |> snag.context("Unable to create thumbnail from file")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "thumbnail")
fn create_thumbnail_ffi(path: String, width: Int) -> Result(ansel.Image, String)
