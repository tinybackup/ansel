import ansel/bounding_box
import ansel/color
import ansel/image
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
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/solid_grey_6x6.avif")

  image.new(6, 6, color.Grey)
  |> result.map(image.to_bit_array(
    _,
    image.AVIF(quality: 100, keep_metadata: True),
  ))
  |> should.equal(Ok(bin))
}

pub fn new_nongrey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  image.new(6, 6, color.GleamLucy)
  |> result.map(image.to_bit_array(
    _,
    image.AVIF(quality: 100, keep_metadata: True),
  ))
  |> should.equal(Ok(bin))
}

pub fn bit_array_avif_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(
    _,
    image.AVIF(quality: 100, keep_metadata: True),
  ))
  |> should.equal(Ok(bin))
}

pub fn bit_array_jpeg_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.jpeg")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(
    _,
    image.JPEG(quality: 100, keep_metadata: True),
  ))
  |> should.equal(Ok(bin))
}

pub fn bit_array_png_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(Ok(bin))
}

pub fn bit_array_webp_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.webp")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(
    _,
    image.WebP(quality: 100, keep_metadata: True),
  ))
  |> should.equal(Ok(bin))
}

pub fn composite_over_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_composite.png")

  let assert Ok(base) = image.new(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) = image.new(width: 6, height: 6, color: color.GleamNavy)

  image.composite_over(base, with: new, at_left: 1, at_top: 1)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(Ok(bin))
}

pub fn extract_area_test() {
  let assert Ok(ext) =
    simplifile.read_bits("test/resources/gleam_extraction.png")

  let assert Ok(base) = image.new(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) = image.new(width: 6, height: 6, color: color.GleamNavy)

  let assert Ok(comp) =
    image.composite_over(base, with: new, at_left: 1, at_top: 1)

  image.extract_area(
    comp,
    at: assert_ltwh(left: 3, top: 3, width: 6, height: 6),
  )
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(Ok(ext))
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

  image.scale_width(img, to: 3)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn resize_width_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)

  image.scale_width(img, to: 12)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 12, height: 8, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn resize_height_down_test() {
  let assert Ok(img) = image.new(width: 6, height: 8, color: color.GleamLucy)

  image.scale_height(img, to: 4)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 3, height: 4, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn resize_height_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamNavy)

  image.scale_height(img, to: 12)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn resize_scale_down_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamLucy)

  image.scale(img, by: 0.5)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn resize_scale_up_test() {
  let assert Ok(img) = image.new(width: 6, height: 4, color: color.GleamNavy)

  image.scale(img, by: 3.0)
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}

pub fn create_thumbnail_test() {
  let thumb =
    image.create_thumbnail("test/resources/gleam_composite.png", width: 9)
    |> result.map(image.to_bit_array(
      _,
      image.JPEG(quality: 70, keep_metadata: True),
    ))
    |> result.replace_error(Nil)

  thumb
  |> should.equal(
    simplifile.read_bits("test/resources/thumb.jpeg")
    |> result.replace_error(Nil),
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
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/fill.png")
    |> result.replace_error(Nil),
  )
}

pub fn outline_test() {
  image.new(width: 20, height: 20, color: color.GleamLucy)
  |> result.try(image.outline(
    _,
    area: assert_ltwh(left: 2, top: 3, width: 10, height: 10),
    with: color.GleamNavy,
    thickness: 2,
  ))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/outline.png")
    |> result.replace_error(Nil),
  )
}

pub fn border_test() {
  image.new(width: 20, height: 20, color: color.SkyBlue)
  |> result.try(image.border(_, with: color.PaleVioletRed, thickness: 10))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/border.png")
    |> result.replace_error(Nil),
  )
}

pub fn round_circle_test() {
  image.new(20, 20, color.GleamLucy)
  |> result.try(image.round(_, by: 1000.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/circle_20x20.png")
    |> result.replace_error(Nil),
  )
}

pub fn round_square_test() {
  image.new(20, 20, color.GleamLucy)
  |> result.try(image.round(_, by: 5.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/rounded_square_20x20.png")
    |> result.replace_error(Nil),
  )
}

pub fn blur_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.blur(_, with: 1.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/blur_13x13.png")
    |> result.replace_error(Nil),
  )
}

pub fn rotate_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 47.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/rotated_47.png")
    |> result.replace_error(Nil),
  )
}

pub fn rotate90_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 90.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/rotated_90.png")
    |> result.replace_error(Nil),
  )
}

pub fn rotate180_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 180.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/rotated_180.png")
    |> result.replace_error(Nil),
  )
}

pub fn rotate270_test() {
  image.read("test/resources/complex_13x13.png")
  |> result.try(image.rotate(_, by: 270.0))
  |> result.map(image.to_bit_array(_, image.PNG))
  |> result.replace_error(Nil)
  |> should.equal(
    simplifile.read_bits("test/resources/rotated_270.png")
    |> result.replace_error(Nil),
  )
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
  list.repeat(list.repeat(color.RGB(255, 175, 243), 6), 6)
  |> image.from_pixel_matrix
  |> result.map(image.to_bit_array(_, image.PNG))
  |> should.equal(
    image.new(6, 6, color.GleamLucy)
    |> result.map(image.to_bit_array(_, image.PNG)),
  )
}
