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
