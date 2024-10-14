//// This module is primarily a wrapper around the Elixir package Vix, which
//// is a wrapper around the great image processing library vips. A pre-built
//// vips binary comes with Vix, but see the readme for more information on
//// how to bring your own to support more image formats.
//// 
//// This module uses the [snag package](https://hexdocs.pm/snag/index.html) for 
//// error handling because vix errors just come back as strings and are not 
//// enumerated. Make sure to install it as well to work with the error messages.
//// 
//// ```gleam
//// import ansel
//// import ansel/image
//// import gleam/result
//// import snag
////
//// pub fn main() {
////   let assert Ok(img) = image.read("input.jpeg")
////
////   image.scale(img, by: 2.0)
////   |> result.try(
////     image.write(_, "output", ansel.JPEG(quality: 60, keep_metadata: False)),
////   )
////   |> snag.context("Unable to process my cool image")
//// }
//// // -> output.jpeg written to disk as a smaller, rounded, bordered version of the
//// //    original image
//// ```

import ansel
import ansel/bounding_box
import ansel/color
import gleam/bool
import gleam/int
import gleam/result
import gleam/string
import snag

/// Image formats supported by vips. All may not be supported by the default
/// vips binary included with this package, you may need to provide your
/// own vips binary on the host system to. See the package readme for details.
/// 
/// The `Custom` constructor allows for advanced vips save options to be 
/// used, like `ansel.Custom(".png[compression=90,squash=true]"), refer to the 
/// [Vix package documentation](https://hexdocs.pm/vix/Vix.Vips.Image.html#write_to_file/2) 
/// for details.
pub type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
  JPEG2000(quality: Int, keep_metadata: Bool)
  JPEGXL(quality: Int, keep_metadata: Bool)
  PNG
  WebP(quality: Int, keep_metadata: Bool)
  AVIF(quality: Int, keep_metadata: Bool)
  TIFF(quality: Int, keep_metadata: Bool)
  HEIC(quality: Int, keep_metadata: Bool)
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
  Custom(format: String)
}

fn image_format_to_string(format: ImageFormat) -> String {
  case format {
    JPEG(quality:, keep_metadata:) ->
      ".jpeg" <> format_common_options(quality, keep_metadata)
    JPEG2000(quality:, keep_metadata:) ->
      ".jp2" <> format_common_options(quality, keep_metadata)
    JPEGXL(quality:, keep_metadata:) ->
      ".jxl" <> format_common_options(quality, keep_metadata)
    PNG -> ".png"
    WebP(quality:, keep_metadata:) ->
      ".webp" <> format_common_options(quality, keep_metadata)
    AVIF(quality:, keep_metadata:) ->
      ".avif" <> format_common_options(quality, keep_metadata)
    TIFF(quality:, keep_metadata:) ->
      ".tiff" <> format_common_options(quality, keep_metadata)
    HEIC(quality:, keep_metadata:) ->
      ".heic" <> format_common_options(quality, keep_metadata)
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
    Custom(format:) -> format
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
  bounding_box bounding_box: bounding_box.BoundingBox,
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

/// Reads a vips image from a bit array
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
pub fn to_bit_array(img: ansel.Image, format: ImageFormat) -> BitArray {
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

/// Places an image over another image, with the top left corner of the
/// overlay image placed at the specified coordinates.
pub fn composite_over(
  base base: ansel.Image,
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

/// Fills in an area of the passed image with a solid color. 
pub fn fill(
  image: ansel.Image,
  in bounding_box: bounding_box.BoundingBox,
  with color: color.Color,
) {
  let #(left, top, width, height) = bounding_box.to_ltwh_tuple(bounding_box)

  new(width:, height:, color:)
  |> result.try(composite_over(image, _, at_left: left, at_top: top))
}

/// Outlines an area in the passed image with a solid color. All
/// outline pixels are written inside the bounding box area.
pub fn outline(
  in image: ansel.Image,
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
    Ok(original_bb) -> {
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

    Error(Nil) -> Ok(filled)
  }
}

/// Add a solid border around the passed image, expanding the 
/// dimensions of the image by the border thickness. Replaces any transparent
/// pixels with the color of the border. This can be used with the round
/// function to add a rounded border to an image.
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

/// Applies a gaussian blur with the given sigma value to an image.
pub fn blur(
  image image: ansel.Image,
  with sigma: Float,
) -> Result(ansel.Image, snag.Snag) {
  gaussblur_ffi(image, sigma)
  |> result.map_error(snag.new)
  |> snag.context("Unable to blur image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "gaussblur")
fn gaussblur_ffi(img: ansel.Image, sigma: Float) -> Result(ansel.Image, String)

/// Rotates an image by the given number of degrees.
pub fn rotate(
  image image: ansel.Image,
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

/// Rounds the corners of an image by a given radius, leaving transparent 
/// pixels where the rounding was applied. A large radius can be given to 
/// create circular images. This can be used with the border function to 
/// create rounded borders around images. This implmentation is heavily 
/// inspired by the extensive elixir library Image.
pub fn round(
  image image: ansel.Image,
  by radius: Float,
) -> Result(ansel.Image, snag.Snag) {
  round_ffi(image, radius)
  |> result.map_error(snag.new)
  |> snag.context("Unable to round image")
}

@external(erlang, "Elixir.Ansel", "round")
fn round_ffi(img: ansel.Image, radius: Float) -> Result(ansel.Image, String)

/// Returns the width of an image.
@external(erlang, "Elixir.Vix.Vips.Image", "width")
pub fn get_width(image: ansel.Image) -> Int

/// Returns the height of an image.
@external(erlang, "Elixir.Vix.Vips.Image", "height")
pub fn get_height(image: ansel.Image) -> Int

/// Returns the dimensions of an image as a bounding box. Useful for bounding
/// box operations.
pub fn to_bounding_box(image image: ansel.Image) -> bounding_box.BoundingBox {
  bounding_box.unchecked_ltwh(
    left: 0,
    top: 0,
    width: get_width(image),
    height: get_height(image),
  )
}

/// Scales an image to the given width, preserving the aspect ratio.
pub fn scale_width(
  image img: ansel.Image,
  to target: Int,
) -> Result(ansel.Image, snag.Snag) {
  scale(img, by: int.to_float(target) /. int.to_float(get_width(img)))
}

/// Scales an image to the given height, preserving the aspect ratio.
pub fn scale_height(
  image img: ansel.Image,
  to target: Int,
) -> Result(ansel.Image, snag.Snag) {
  scale(img, by: int.to_float(target) /. int.to_float(get_height(img)))
}

/// Resizes an image by the given scale, preserving the aspect ratio.
pub fn scale(
  image img: ansel.Image,
  by scale: Float,
) -> Result(ansel.Image, snag.Snag) {
  resize_ffi(img, scale)
  |> result.map_error(snag.new)
  |> snag.context("Unable to resize image")
}

@external(erlang, "Elixir.Vix.Vips.Operation", "resize")
fn resize_ffi(img: ansel.Image, scale: Float) -> Result(ansel.Image, String)

/// Writes an image to the specified path in the specified format.
pub fn write(
  image img: ansel.Image,
  to path: String,
  in format: ImageFormat,
) -> Result(Nil, snag.Snag) {
  write_ffi(img, path <> image_format_to_string(format))
  |> result.map_error(snag.new)
  |> snag.context("Unable to write image to file")
}

@external(erlang, "Elixir.Ansel", "write_to_file")
fn write_ffi(img: ansel.Image, to path: String) -> Result(Nil, String)

/// Reads an image from the specified path.
pub fn read(from path: String) -> Result(ansel.Image, snag.Snag) {
  read_ffi(path)
  |> result.map_error(snag.new)
  |> snag.context("Unable to read image from file")
}

@external(erlang, "Elixir.Ansel", "read")
fn read_ffi(from path: String) -> Result(ansel.Image, String)

/// Creates a thumbnail of an image at the specified path with the given width.
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
