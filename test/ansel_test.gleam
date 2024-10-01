import ansel
import ansel/bounding_box
import ansel/color
import gleam/result
import gleeunit
import gleeunit/should
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn read_test() {
  let assert Ok(img) = ansel.read("test/resources/gleam_lucy_6x6.avif")

  ansel.get_width(img)
  |> should.equal(6)
}

pub fn new_image_solid_grey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/solid_grey_6x6.avif")

  ansel.new_image(6, 6, color.Grey)
  |> result.map(ansel.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn new_image_nongrey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  ansel.new_image(6, 6, color.GleamLucy)
  |> result.map(ansel.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_avif_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ansel.AVIF(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_jpg_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.jpg")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ansel.JPG(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn bit_array_png_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(bin))
}

pub fn bit_array_webp_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.webp")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ansel.WEBP(quality: 100)))
  |> should.equal(Ok(bin))
}

pub fn composite_over_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_composite.png")

  let assert Ok(base) =
    ansel.new_image(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) =
    ansel.new_image(width: 6, height: 6, color: color.GleamNavy)

  ansel.composite_over(base, with: new, at_left_position: 1, at_top_position: 1)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(bin))
}

pub fn extract_area_test() {
  let assert Ok(ext) =
    simplifile.read_bits("test/resources/gleam_extraction.png")

  let assert Ok(base) =
    ansel.new_image(width: 12, height: 12, color: color.GleamLucy)

  let assert Ok(new) =
    ansel.new_image(width: 6, height: 6, color: color.GleamNavy)

  let assert Ok(comp) =
    ansel.composite_over(
      base,
      with: new,
      at_left_position: 1,
      at_top_position: 1,
    )

  ansel.extract_area(
    comp,
    at: bounding_box.LTWH(left: 3, top: 3, width: 6, height: 6),
  )
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(Ok(ext))
}

pub fn get_width_test() {
  let assert Ok(img) =
    ansel.new_image(width: 2, height: 6, color: color.GleamLucy)

  ansel.get_width(img)
  |> should.equal(2)
}

pub fn get_height_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamLucy)

  ansel.get_height(img)
  |> should.equal(4)
}

pub fn resize_width_down_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamLucy)

  ansel.resize_width_to(img, res: 3)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_width_up_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamLucy)

  ansel.resize_width_to(img, res: 12)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 12, height: 8, color: color.GleamLucy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_height_down_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 8, color: color.GleamLucy)

  ansel.resize_height_to(img, res: 4)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 3, height: 4, color: color.GleamLucy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_height_up_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamNavy)

  ansel.resize_height_to(img, res: 12)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_scale_down_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamLucy)

  ansel.resize_by(img, scale: 0.5)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 3, height: 2, color: color.GleamLucy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}

pub fn resize_scale_up_test() {
  let assert Ok(img) =
    ansel.new_image(width: 6, height: 4, color: color.GleamNavy)

  ansel.resize_by(img, scale: 3.0)
  |> result.map(ansel.to_bit_array(_, ansel.PNG))
  |> should.equal(
    ansel.new_image(width: 18, height: 12, color: color.GleamNavy)
    |> result.map(ansel.to_bit_array(_, ansel.PNG)),
  )
}
