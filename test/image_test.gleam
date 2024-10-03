import ansel
import ansel/color
import ansel/fixed_bounding_box
import ansel/image
import gleam/result
import gleeunit
import gleeunit/should
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn read_test() {
  let assert Ok(img) = image.read("test/resources/gleam_lucy_6x6.avif")

  image.get_width(img)
  |> should.equal(6)
}

pub fn new_image_solid_grey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/solid_grey_6x6.avif")

  image.new_image(6, 6, color.Grey)
  |> result.map(image.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn new_image_nongrey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  image.new_image(6, 6, color.GleamLucy)
  |> result.map(image.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_avif_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_jpeg_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.jpeg")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(_, ansel.JPEG(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_png_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(bin))
}

pub fn bit_array_webp_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.webp")

  image.from_bit_array(bin)
  |> result.map(image.to_bit_array(_, ansel.WebP(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn composite_over_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_composite.png")

  let assert Ok(base) =
    image.new_image(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) =
    image.new_image(width: 6, height: 6, color: color.GleamNavy)

  image.composite_over(base, with: new, at_left: 1, at_top: 1)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(bin))
}

pub fn extract_area_test() {
  let assert Ok(ext) =
    simplifile.read_bits("test/resources/gleam_extraction.png")

  let assert Ok(base) =
    image.new_image(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) =
    image.new_image(width: 6, height: 6, color: color.GleamNavy)

  let assert Ok(comp) =
    image.composite_over(base, with: new, at_left: 1, at_top: 1)

  image.extract_area(
    comp,
    at: fixed_bounding_box.LTWH(left: 3, top: 3, width: 6, height: 6),
  )
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(ext))
}

pub fn get_width_test() {
  let assert Ok(img) =
    image.new_image(width: 2, height: 6, color: color.GleamLucy)

  image.get_width(img)
  |> should.equal(2)
}

pub fn get_height_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamLucy)

  image.get_height(img)
  |> should.equal(4)
}

pub fn resize_width_down_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamLucy)

  image.resize_width_to(img, resolution: 3)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_width_up_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamLucy)

  image.resize_width_to(img, resolution: 12)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 12, height: 8, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_height_down_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 8, color: color.GleamLucy)

  image.resize_height_to(img, resolution: 4)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 3, height: 4, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_height_up_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamNavy)

  image.resize_height_to(img, resolution: 12)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_scale_down_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamLucy)

  image.resize_by(img, scale: 0.5)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_scale_up_test() {
  let assert Ok(img) =
    image.new_image(width: 6, height: 4, color: color.GleamNavy)

  image.resize_by(img, scale: 3.0)
  |> result.map(image.to_bit_array(_, ansel.PNG))
  |> should.equal(
    image.new_image(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(image.to_bit_array(_, ansel.PNG)),
  )
}

pub fn create_thumbnail_test() {
  let thumb =
    image.create_thumbnail("test/resources/gleam_composite.png", width: 9)
    |> result.map(image.to_bit_array(_, ansel.JPEG(quality: 70)))
    |> result.replace_error(Nil)

  thumb
  |> should.equal(
    simplifile.read_bits("test/resources/thumb.jpeg")
    |> result.replace_error(Nil),
  )
}

pub fn fit_fixed_bounding_box_width_test() {
  let assert Ok(img) = image.new_image(width: 6, height: 4, color: color.Blue)

  let assert Ok(fit) =
    image.fit_fixed_bounding_box(
      fixed_bounding_box.LTWH(left: 1, top: 2, width: 30, height: 2),
      in: img,
    )

  fit
  |> fixed_bounding_box.to_ltwh_tuple
  |> should.equal(
    fixed_bounding_box.LTWH(left: 1, top: 2, width: 5, height: 2)
    |> fixed_bounding_box.to_ltwh_tuple,
  )
}

pub fn fit_fixed_bounding_box_height_test() {
  let assert Ok(img) = image.new_image(width: 6, height: 4, color: color.Blue)

  let assert Ok(fit) =
    image.fit_fixed_bounding_box(
      fixed_bounding_box.LTWH(left: 1, top: 2, width: 2, height: 30),
      in: img,
    )

  fit
  |> fixed_bounding_box.to_ltwh_tuple
  |> should.equal(
    fixed_bounding_box.LTWH(left: 1, top: 2, width: 2, height: 2)
    |> fixed_bounding_box.to_ltwh_tuple,
  )
}

pub fn fit_fixed_bounding_box_no_possible_fit_test() {
  let assert Ok(img) = image.new_image(width: 6, height: 4, color: color.Blue)

  image.fit_fixed_bounding_box(
    fixed_bounding_box.LTWH(left: 10, top: 22, width: 30, height: 44),
    in: img,
  )
  |> should.equal(Error(Nil))
}
