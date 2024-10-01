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

pub fn new_image_solid_grey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/solid_grey_6x6.avif")

  ansel.new_image(6, 6, color.Grey)
  |> result.map(ansel.to_bit_array(_, ".avif"))
  |> should.equal(Ok(bin))
}

pub fn new_image_nongrey_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  ansel.new_image(6, 6, color.GleamLucy)
  |> result.map(ansel.to_bit_array(_, ".avif"))
  |> should.equal(Ok(bin))
}

pub fn bit_array_avif_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.avif")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ".avif"))
  |> should.equal(Ok(bin))
}

pub fn bit_array_jpg_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.jpg")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ".jpg"))
  |> should.equal(Ok(bin))
}

pub fn bit_array_png_round_trip_test() {
  let assert Ok(bin) = simplifile.read_bits("test/resources/gleam_lucy_6x6.png")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ".png"))
  |> should.equal(Ok(bin))
}

pub fn bit_array_webp_round_trip_test() {
  let assert Ok(bin) =
    simplifile.read_bits("test/resources/gleam_lucy_6x6.webp")

  ansel.from_bit_array(bin)
  |> result.map(ansel.to_bit_array(_, ".webp"))
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
  |> result.map(ansel.to_bit_array(_, ".png"))
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
  |> result.map(ansel.to_bit_array(_, ".png"))
  |> should.equal(Ok(ext))
}
