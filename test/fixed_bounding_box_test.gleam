import ansel/fixed_bounding_box
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn shrink_by_one_test() {
  fixed_bounding_box.LTWH(left: 1, top: 2, width: 3, height: 4)
  |> fixed_bounding_box.shrink(by: 1)
  |> should.equal(fixed_bounding_box.LTWH(left: 2, top: 3, width: 1, height: 2))
}

pub fn shrink_big_test() {
  fixed_bounding_box.LTWH(left: 10, top: 20, width: 300, height: 900)
  |> fixed_bounding_box.shrink(by: 50)
  |> should.equal(fixed_bounding_box.LTWH(
    left: 60,
    top: 70,
    width: 200,
    height: 800,
  ))
}

pub fn expand_by_one_test() {
  fixed_bounding_box.LTWH(left: 1, top: 2, width: 3, height: 4)
  |> fixed_bounding_box.expand(by: 1)
  |> should.equal(fixed_bounding_box.LTWH(left: 0, top: 1, width: 5, height: 6))
}

pub fn expand_big_test() {
  fixed_bounding_box.LTWH(left: 100, top: 200, width: 300, height: 800)
  |> fixed_bounding_box.expand(by: 50)
  |> should.equal(fixed_bounding_box.LTWH(
    left: 50,
    top: 150,
    width: 400,
    height: 900,
  ))
}

pub fn cut_miss_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 10, top: 10, width: 10, height: 10)

  let cutter =
    fixed_bounding_box.LTWH(left: 50, top: 50, width: 100, height: 100)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([to_cut])
}

pub fn cut_top_border_test() {
  let to_cut =
    fixed_bounding_box.LTWH(left: 100, top: 100, width: 100, height: 100)

  let cutter =
    fixed_bounding_box.LTWH(left: 125, top: 50, width: 50, height: 100)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 100, top: 100, width: 25, height: 50),
    fixed_bounding_box.LTWH(left: 175, top: 100, width: 25, height: 50),
    fixed_bounding_box.LTWH(left: 100, top: 150, width: 100, height: 50),
  ])
}

pub fn cut_bottom_border_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 4, top: 7, width: 2, height: 50)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 7),
    fixed_bounding_box.LTWH(left: 0, top: 7, width: 4, height: 3),
    fixed_bounding_box.LTWH(left: 6, top: 7, width: 4, height: 3),
  ])
}

pub fn cut_right_border_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 10, top: 10, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 15, top: 15, width: 5, height: 3)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 10, top: 10, width: 10, height: 5),
    fixed_bounding_box.LTWH(left: 10, top: 15, width: 5, height: 3),
    fixed_bounding_box.LTWH(left: 10, top: 18, width: 10, height: 2),
  ])
}

pub fn cut_left_border_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 0, top: 7, width: 2, height: 2)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 7),
    fixed_bounding_box.LTWH(left: 2, top: 7, width: 8, height: 2),
    fixed_bounding_box.LTWH(left: 0, top: 9, width: 10, height: 1),
  ])
}

pub fn cut_top_left_borders_test() {
  let to_cut =
    fixed_bounding_box.LTWH(left: 100, top: 100, width: 100, height: 100)

  let cutter =
    fixed_bounding_box.LTWH(left: 50, top: 50, width: 100, height: 100)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 150, top: 100, width: 50, height: 50),
    fixed_bounding_box.LTWH(left: 100, top: 150, width: 100, height: 50),
  ])
}

pub fn cut_top_right_borders_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 7, top: 0, width: 3, height: 2)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 7, height: 2),
    fixed_bounding_box.LTWH(left: 0, top: 2, width: 10, height: 8),
  ])
}

pub fn cut_left_bottom_borders_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 0, top: 7, width: 3, height: 3)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 7),
    fixed_bounding_box.LTWH(left: 3, top: 7, width: 7, height: 3),
  ])
}

pub fn cut_right_bottom_borders_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 7, top: 6, width: 3, height: 4)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 6),
    fixed_bounding_box.LTWH(left: 0, top: 6, width: 7, height: 4),
  ])
}

pub fn cut_center_test() {
  let to_cut = fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)

  let cutter = fixed_bounding_box.LTWH(left: 5, top: 5, width: 3, height: 3)

  fixed_bounding_box.cut(to_cut, cutter)
  |> should.equal([
    fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 5),
    fixed_bounding_box.LTWH(left: 0, top: 5, width: 5, height: 3),
    fixed_bounding_box.LTWH(left: 8, top: 5, width: 2, height: 3),
    fixed_bounding_box.LTWH(left: 0, top: 8, width: 10, height: 2),
  ])
}

pub fn resize_by_2_test() {
  fixed_bounding_box.LTWH(left: 0, top: 0, width: 10, height: 10)
  |> fixed_bounding_box.resize_by(scale: 2.0)
  |> should.equal(fixed_bounding_box.LTRB(
    left: 0,
    top: 0,
    right: 20,
    bottom: 20,
  ))
}

pub fn resize_by_half_test() {
  fixed_bounding_box.LTWH(left: 0, top: 0, width: 20, height: 10)
  |> fixed_bounding_box.resize_by(scale: 0.5)
  |> should.equal(fixed_bounding_box.LTRB(left: 0, top: 0, right: 10, bottom: 5))
}

pub fn resize_by_odd_test() {
  fixed_bounding_box.LTWH(left: 2, top: 2, width: 3, height: 3)
  |> fixed_bounding_box.resize_by(scale: 1.5)
  |> should.equal(fixed_bounding_box.LTRB(left: 3, top: 3, right: 8, bottom: 8))
}

pub fn resize_large_downscale_test() {
  fixed_bounding_box.LTWH(2047, 962, 38, 45)
  |> fixed_bounding_box.resize_by(scale: 0.33)
  |> should.equal(fixed_bounding_box.LTRB(
    left: 676,
    top: 317,
    right: 688,
    bottom: 332,
  ))
}

pub fn intersection_test() {
  let box1 = fixed_bounding_box.LTRB(left: 2, top: 2, right: 6, bottom: 5)
  let box2 = fixed_bounding_box.LTRB(left: 4, top: 4, right: 8, bottom: 7)

  fixed_bounding_box.intersection(box1, box2)
  |> should.equal(
    Some(fixed_bounding_box.LTRB(left: 4, top: 4, right: 6, bottom: 5)),
  )
}

pub fn intersection_none_test() {
  let box1 = fixed_bounding_box.LTRB(left: 2, top: 2, right: 6, bottom: 5)
  let box2 = fixed_bounding_box.LTRB(left: 10, top: 10, right: 12, bottom: 11)

  fixed_bounding_box.intersection(box1, box2)
  |> should.equal(None)
}

pub fn intersection_completely_within_test() {
  let box1 = fixed_bounding_box.LTRB(left: 0, top: 0, right: 10, bottom: 10)
  let box2 = fixed_bounding_box.LTRB(left: 4, top: 4, right: 8, bottom: 7)

  fixed_bounding_box.intersection(box1, box2)
  |> should.equal(Some(box2))
}
