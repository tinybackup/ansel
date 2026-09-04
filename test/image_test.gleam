import ansel
import ansel/bounding_box
import ansel/color
import ansel/image
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should
import simplifile

pub fn main() {
  gleeunit.main()
}

fn assert_ltwh(left l: Int, top t: Int, width w: Int, height h: Int) {
  let assert Ok(value) = bounding_box.ltwh(left: l, top: t, width: w, height: h)
  value
}

/// The bands of every pixel of an image, row by row, like
/// [[[255, 175, 243], ...], ...]. The tests compare these instead of encoded
/// image bytes, as a different build of vips can encode the same pixels into
/// different bytes.
type Pixels =
  List(List(List(Int)))

@external(erlang, "Elixir.Vix.Vips.Image", "to_list")
fn to_pixels(image: ansel.Image) -> Result(Pixels, String)

fn pixels_of(image: ansel.Image) -> Pixels {
  to_pixels(image) |> should.be_ok
}

fn pixels_of_file(path: String) -> Pixels {
  image.read(path) |> should.be_ok |> pixels_of
}

/// Asserts an image has exactly the given pixels. Only for operations that
/// work out the same pixels every time, like compositing or a quarter turn.
fn should_have_pixels(image: ansel.Image, expected: Pixels) {
  should_have_pixels_within(image, expected, tolerance: 0)
}

/// Asserts an image has the given pixels, give or take the tolerance, for
/// operations that do not have to give the same answer to the last band value
/// on every machine, like lossy encoders and interpolation.
fn should_have_pixels_within(
  image: ansel.Image,
  expected: Pixels,
  tolerance tolerance: Int,
) {
  let actual = pixels_of(image)

  size_of(actual)
  |> should.equal(size_of(expected))

  let difference = max_band_difference(actual, expected)

  case difference <= tolerance {
    True -> Nil
    False ->
      panic as string.concat([
          "\nPixel bands differ by up to ",
          int.to_string(difference),
          "\nshould differ by at most ",
          int.to_string(tolerance),
        ])
  }
}

fn size_of(pixels: Pixels) -> #(Int, Int, Int) {
  let first_row = pixels |> list.first |> result.unwrap([])
  let first_pixel = first_row |> list.first |> result.unwrap([])

  #(list.length(pixels), list.length(first_row), list.length(first_pixel))
}

fn max_band_difference(actual: Pixels, expected: Pixels) -> Int {
  list.zip(actual, expected)
  |> list.fold(0, fn(difference, rows) {
    let #(actual_row, expected_row) = rows

    list.zip(actual_row, expected_row)
    |> list.fold(difference, fn(difference, pixels) {
      let #(actual_pixel, expected_pixel) = pixels

      list.zip(actual_pixel, expected_pixel)
      |> list.fold(difference, fn(difference, bands) {
        let #(actual_band, expected_band) = bands

        int.max(difference, int.absolute_value(actual_band - expected_band))
      })
    })
  })
}

pub fn read_test() {
  let assert Ok(img) = image.read("test/resources/gleam_lucy_6x6.avif")

  image.get_width(img)
  |> should.equal(6)
}

pub fn write_test() {
  let path = "test/tmp_write_test_asset"

  let output_path =
    image.new(5, 5, color.GleamLucy)
    |> should.be_ok
    |> image.write(path, image.JPEG(quality: 100, keep_metadata: True))
    |> should.be_ok()

  string.ends_with(output_path, "jpeg")
  |> should.be_true()

  image.read(output_path)
  |> should.be_ok
  |> image.get_width
  |> should.equal(5)

  let assert Ok(_) = simplifile.delete(output_path)
}

pub fn custom_options_test() {
  let assert Ok(reference_image) = image.new(6, 6, color.Grey)
  let output =
    reference_image
    |> image.to_bit_array(image.JPEG(quality: 50, keep_metadata: True))

  reference_image
  |> image.to_bit_array(image.Custom(".jpeg", "Q=50,strip=false"))
  |> should.equal(output)
}

pub fn new_solid_grey_test() {
  image.new(6, 6, color.Grey)
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/solid_grey_6x6.avif"),
    tolerance: 2,
  )
}

pub fn new_nongrey_test() {
  image.new(6, 6, color.GleamLucy)
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/gleam_lucy_6x6.avif"),
    tolerance: 2,
  )
}

pub fn bit_array_avif_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  let original = image.from_bit_array(bin) |> should.be_ok

  original
  |> image.to_bit_array(image.AVIF(quality: 100, keep_metadata: True))
  |> image.from_bit_array
  |> should.be_ok
  |> should_have_pixels_within(pixels_of(original), tolerance: 2)
}

pub fn bit_array_jpeg_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.jpeg")

  let original = image.from_bit_array(bin) |> should.be_ok

  original
  |> image.to_bit_array(image.JPEG(quality: 100, keep_metadata: True))
  |> image.from_bit_array
  |> should.be_ok
  |> should_have_pixels_within(pixels_of(original), tolerance: 2)
}

pub fn bit_array_png_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  let original = image.from_bit_array(bin) |> should.be_ok

  original
  |> image.to_bit_array(image.PNG)
  |> image.from_bit_array
  |> should.be_ok
  |> should_have_pixels(pixels_of(original))
}

pub fn bit_array_webp_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.webp")

  let original = image.from_bit_array(bin) |> should.be_ok

  original
  |> image.to_bit_array(image.WebP(quality: 100, keep_metadata: True))
  |> image.from_bit_array
  |> should.be_ok
  |> should_have_pixels_within(pixels_of(original), tolerance: 2)
}

pub fn composite_over_test() {
  let assert Ok(base) = image.new(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) = image.new(width: 6, height: 6, color: color.GleamNavy)

  image.composite_over(base, with: new, at_left: 1, at_top: 1)
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/gleam_composite.png"))
}

pub fn extract_area_test() {
  let assert Ok(base) = image.new(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) = image.new(width: 6, height: 6, color: color.GleamNavy)

  let assert Ok(comp) =
    image.composite_over(base, with: new, at_left: 1, at_top: 1)

  image.extract_area(
    comp,
    at: assert_ltwh(left: 3, top: 3, width: 6, height: 6),
  )
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/gleam_extraction.png"))
}

pub fn get_width_test() {
  let assert Ok(img) = image.new(width: 2, height: 6, color: color.GleamLucy)

  image.get_width(img)
  |> should.equal(2)
}

pub fn get_height_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)

  image.get_height(img)
  |> should.equal(4)
}

pub fn resize_width_down_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)
  let assert Ok(expected) =
    image.new(width: 3, height: 2, color: color.GleamLucy)

  image.scale_width(img, to: 3)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn resize_width_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)
  let assert Ok(expected) =
    image.new(width: 12, height: 8, color: color.GleamLucy)

  image.scale_width(img, to: 12)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn resize_height_down_test() {
  let assert Ok(img) = image.new(width: 6, height: 8, color: color.GleamLucy)
  let assert Ok(expected) =
    image.new(width: 3, height: 4, color: color.GleamLucy)

  image.scale_height(img, to: 4)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn resize_height_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamNavy)
  let assert Ok(expected) =
    image.new(width: 18, height: 12, color: color.GleamNavy)

  image.scale_height(img, to: 12)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn resize_scale_down_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)
  let assert Ok(expected) =
    image.new(width: 3, height: 2, color: color.GleamLucy)

  image.scale(img, by: 0.5)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn resize_scale_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamNavy)
  let assert Ok(expected) =
    image.new(width: 18, height: 12, color: color.GleamNavy)

  image.scale(img, by: 3.0)
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn create_thumbnail_test() {
  image.create_thumbnail("test/resources/gleam_composite.png", width: 9)
  |> should.be_ok
  |> image.to_bit_array(image.JPEG(quality: 70, keep_metadata: True))
  |> image.from_bit_array
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/thumb.jpeg"),
    tolerance: 2,
  )
}

pub fn fit_bounding_box_width_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.Blue)

  let assert Ok(fit) =
    image.fit_bounding_box(
      assert_ltwh(left: 1, top: 2, width: 30, height: 2),
      in: img,
    )

  fit
  |> bounding_box.to_ltwh_tuple
  |> should.equal(
    assert_ltwh(left: 1, top: 2, width: 5, height: 2)
    |> bounding_box.to_ltwh_tuple,
  )
}

pub fn fit_bounding_box_height_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.Blue)

  let assert Ok(fit) =
    image.fit_bounding_box(
      assert_ltwh(left: 1, top: 2, width: 2, height: 30),
      in: img,
    )

  fit
  |> bounding_box.to_ltwh_tuple
  |> should.equal(
    assert_ltwh(left: 1, top: 2, width: 2, height: 2)
    |> bounding_box.to_ltwh_tuple,
  )
}

pub fn fit_bounding_box_no_possible_fit_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.Blue)

  image.fit_bounding_box(
    assert_ltwh(left: 10, top: 22, width: 30, height: 44),
    in: img,
  )
  |> should.be_error
}

pub fn fill_test() {
  image.new(width: 10, height: 10, color: color.Grey)
  |> result.try(image.fill(
    _,
    in: assert_ltwh(left: 0, top: 0, width: 5, height: 5),
    with: color.Blue,
  ))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/fill.png"))
}

pub fn outline_test() {
  image.new(width: 20, height: 20, color: color.GleamLucy)
  |> result.try(image.outline(
    _,
    area: assert_ltwh(left: 2, top: 3, width: 10, height: 10),
    with: color.GleamNavy,
    thickness: 2,
  ))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/outline.png"))
}

pub fn border_test() {
  image.new(width: 20, height: 20, color: color.SkyBlue)
  |> result.try(image.border(_, with: color.PaleVioletRed, thickness: 10))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/border.png"))
}

pub fn round_circle_test() {
  image.new(20, 20, color.GleamLucy)
  |> result.try(image.round(_, by: 1000.0))
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/circle_20x20.png"),
    tolerance: 2,
  )
}

pub fn round_square_test() {
  image.new(20, 20, color.GleamLucy)
  |> result.try(image.round(_, by: 5.0))
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/rounded_square_20x20.png"),
    tolerance: 2,
  )
}

pub fn blur_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.blur(_, with: 1.0))
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/blur_13x13.png"),
    tolerance: 2,
  )
}

pub fn rotate_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 47.0))
  |> should.be_ok
  |> should_have_pixels_within(
    pixels_of_file("test/resources/rotated_47.png"),
    tolerance: 2,
  )
}

pub fn rotate90_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 90.0))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/rotated_90.png"))
}

pub fn rotate180_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 180.0))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/rotated_180.png"))
}

pub fn rotate270_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 270.0))
  |> should.be_ok
  |> should_have_pixels(pixels_of_file("test/resources/rotated_270.png"))
}

pub fn to_pixel_list_success_test() {
  image.new(6, 6, color.GleamLucy)
  |> result.try(image.to_pixel_matrix)
  |> should.be_ok
}

pub fn to_pixel_list_size_test() {
  image.new(6, 6, color.GleamLucy)
  |> result.try(image.to_pixel_matrix)
  |> result.map(fn(pixel_rows) {
    #(
      list.length(pixel_rows),
      pixel_rows |> list.first |> result.unwrap([]) |> list.length,
    )
  })
  |> should.equal(Ok(#(6, 6)))
}

pub fn to_pixel_list_value_test() {
  image.new(6, 6, color.GleamLucy)
  |> result.try(image.to_pixel_matrix)
  |> result.map(fn(pixel_rows) {
    pixel_rows
    |> list.all(fn(pixel_row) {
      pixel_row
      |> list.all(fn(pixel) { pixel == color.RGB(255, 175, 243) })
    })
  })
  |> should.equal(Ok(True))
}

pub fn from_pixel_list_success_test() {
  list.repeat(list.repeat(color.RGB(255, 175, 243), 6), 6)
  |> image.from_pixel_matrix
  |> should.be_ok
}

pub fn from_pixel_list_success_size_test() {
  list.repeat(list.repeat(color.RGB(255, 175, 243), 6), 6)
  |> image.from_pixel_matrix
  |> result.map(fn(image) { #(image.get_height(image), image.get_width(image)) })
  |> should.equal(Ok(#(6, 6)))
}

pub fn from_pixel_list_success_value_test() {
  let assert Ok(expected) = image.new(6, 6, color.GleamLucy)

  list.repeat(list.repeat(color.RGB(255, 175, 243), 6), 6)
  |> image.from_pixel_matrix
  |> should.be_ok
  |> should_have_pixels(pixels_of(expected))
}

pub fn pixel_matrix_round_trip_dimensions_test() {
  let height = 100
  let width = 50

  let assert Ok(original_img) = image.new(width, height, color.GleamLucy)
  let original_size = #(
    image.get_height(original_img),
    image.get_width(original_img),
  )

  let assert Ok(pixel_matrix) = image.to_pixel_matrix(original_img)

  // Verify pixel matrix dimensions match original
  let matrix_size = #(
    list.length(pixel_matrix),
    pixel_matrix |> list.first |> result.unwrap([]) |> list.length,
  )
  matrix_size |> should.equal(original_size)

  let assert Ok(converted_img) = image.from_pixel_matrix(pixel_matrix)
  let converted_size = #(
    image.get_height(converted_img),
    image.get_width(converted_img),
  )

  converted_size |> should.equal(original_size)
}

const animated_gif = "test/resources/animated_8x8_3frames.gif"

pub fn from_bit_array_reads_first_frame_only_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let img = image.from_bit_array(bin) |> should.be_ok

  image.get_width(img)
  |> should.equal(8)

  image.get_height(img)
  |> should.equal(8)

  image.get_n_pages(img)
  |> should.equal(1)
}

pub fn from_bit_array_with_options_reads_all_frames_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let img =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok

  image.get_width(img)
  |> should.equal(8)

  // All three frames are read into one image, stacked on top of each other
  image.get_height(img)
  |> should.equal(24)

  image.get_n_pages(img)
  |> should.equal(3)
}

pub fn from_bit_array_with_enum_option_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  image.from_bit_array_with_options(
    bin,
    options: "n=2,access=VIPS_ACCESS_SEQUENTIAL",
  )
  |> should.be_ok
  |> image.get_height
  |> should.equal(16)
}

pub fn from_bit_array_with_unsupported_option_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  // The png loader has no n option, so it is ignored
  image.from_bit_array_with_options(bin, options: "n=-1")
  |> should.be_ok
  |> image.get_height
  |> should.equal(6)
}

pub fn from_bit_array_with_unknown_option_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  image.from_bit_array_with_options(bin, options: "wibble=-1,n=-1")
  |> should.be_ok
  |> image.get_n_pages
  |> should.equal(3)
}

pub fn from_bit_array_with_bad_option_value_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  // The n option is a number, not a word
  image.from_bit_array_with_options(bin, options: "n=all")
  |> should.be_error
}

pub fn write_all_frames_test() {
  let path = "test/tmp_write_animated_test_asset"
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let output_path =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok
    |> image.write(path, image.GIF)
    |> should.be_ok

  let assert Ok(written) = simplifile.read_bits(output_path)

  // The written image still holds all three frames
  image.from_bit_array_with_options(written, options: "n=-1")
  |> should.be_ok
  |> image.get_height
  |> should.equal(24)

  let assert Ok(_) = simplifile.delete(output_path)
}

pub fn n_pages_of_still_image_test() {
  let assert Ok(img) = image.new(width: 6, height: 6, color: color.GleamLucy)

  image.get_n_pages(img)
  |> should.equal(1)
}

pub fn scale_all_pages_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let scaled =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok
    |> image.scale(by: 2.0)
    |> should.be_ok

  image.get_n_pages(scaled)
  |> should.equal(3)

  image.get_width(scaled)
  |> should.equal(16)

  image.get_height(scaled)
  |> should.equal(48)
}

pub fn scale_width_all_pages_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let scaled =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok
    |> image.scale_width(to: 4)
    |> should.be_ok

  image.get_n_pages(scaled)
  |> should.equal(3)

  image.get_height(scaled)
  |> should.equal(12)
}

pub fn scale_height_all_pages_test() {
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  // The target height is the height of a single page, not of the whole stack
  let scaled =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok
    |> image.scale_height(to: 4)
    |> should.be_ok

  image.get_n_pages(scaled)
  |> should.equal(3)

  image.get_width(scaled)
  |> should.equal(4)

  image.get_height(scaled)
  |> should.equal(12)
}

pub fn write_scaled_pages_test() {
  let path = "test/tmp_write_scaled_animated_test_asset"
  let assert Ok(bin) = simplifile.read_bits(animated_gif)

  let output_path =
    image.from_bit_array_with_options(bin, options: "n=-1")
    |> should.be_ok
    |> image.scale(by: 2.0)
    |> should.be_ok
    |> image.write(path, image.GIF)
    |> should.be_ok

  let assert Ok(written) = simplifile.read_bits(output_path)

  // The scaled image is written with all three of its frames
  let img =
    image.from_bit_array_with_options(written, options: "n=-1")
    |> should.be_ok

  image.get_n_pages(img)
  |> should.equal(3)

  image.get_width(img)
  |> should.equal(16)

  let assert Ok(_) = simplifile.delete(output_path)
}

pub fn read_with_options_test() {
  let img = image.read(animated_gif <> "[n=-1]") |> should.be_ok

  image.get_n_pages(img)
  |> should.equal(3)

  image.get_height(img)
  |> should.equal(24)
}
