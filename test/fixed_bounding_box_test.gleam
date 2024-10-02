import ansel/fixed_bounding_box
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
