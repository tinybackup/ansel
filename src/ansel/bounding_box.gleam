//// A module for working with bounding boxes in Ansel. Bounding boxes are a 
//// common way to represent rectangular areas in images, and can be used to 
//// crop images, fill in images, and highlight areas of images.
//// 
//// ```gleam
//// let assert Ok(box) = bounding_box.x1y1x2y2(2, 2, 4, 4)
//// 
//// bounding_box.expand(box, by: 2)
//// |> image.extract_area(image, at: _)
//// ```

import gleam/bool
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import snag

/// A representation of a rectangular area in any given image.
pub opaque type BoundingBox {
  LTWH(left: Int, top: Int, width: Int, height: Int)
  LTRB(left: Int, top: Int, right: Int, bottom: Int)
  X1Y1X2Y2(x1: Int, y1: Int, x2: Int, y2: Int)
}

/// Creates a new bounding box from the given values in the (Left, Top), (Width, 
/// Height) rectangular coordinate format.
pub fn ltwh(
  left left: Int,
  top top: Int,
  width width: Int,
  height height: Int,
) -> Result(BoundingBox, snag.Snag) {
  case width > 0 && height > 0 && left >= 0 && top >= 0 {
    True -> Ok(LTWH(left: left, top: top, width: width, height: height))
    False -> snag.error("Impossible ltwh bounding box values passed")
  }
}

@internal
pub fn unchecked_ltwh(
  left left: Int,
  top top: Int,
  width width: Int,
  height height: Int,
) -> BoundingBox {
  LTWH(left: left, top: top, width: width, height: height)
}

/// Creates a new bounding box from the given values in the (Left, Top), (Right, 
/// Bottom) rectangular coordinate format.
pub fn ltrb(
  left left: Int,
  top top: Int,
  right right: Int,
  bottom bottom: Int,
) -> Result(BoundingBox, snag.Snag) {
  case left < right && top < bottom && left >= 0 && top >= 0 {
    True -> Ok(LTRB(left: left, top: top, right: right, bottom: bottom))
    False -> snag.error("Impossible ltrb bounding box values passed")
  }
}

/// Creates a new bounding box from the given values in the (x1, y1), (x2, y2) 
/// rectangular coordinate format.
pub fn x1y1x2y2(
  x1 x1: Int,
  y1 y1: Int,
  x2 x2: Int,
  y2 y2: Int,
) -> Result(BoundingBox, snag.Snag) {
  case x1 < x2 && y1 < y2 && x1 >= 0 && y1 >= 0 {
    True -> Ok(X1Y1X2Y2(x1: x1, y1: y1, x2: x2, y2: y2))
    False -> snag.error("Impossible x1y1x2y2 bounding box values passed")
  }
}

/// Converts a bounding box to a tuple with the coordinate values left, top, 
/// width, height. Useful for working with with custom bounding box operations
/// and getting the width and height of a bounding box.
/// 
/// ## Example
/// ```gleam
/// let assert Ok(box) = bounding_box.x1y1x2y2(x1: 2, y1: 2, x2: 6, y2: 6) 
/// bounding_box.to_ltwh_tuple(box)
/// // -> #(2, 2, 4, 4)
/// ```
/// 
/// ```gleam
/// let assert Ok(box) = bounding_box.x1y1x2y2(x1: 4, y1: 4, x2: 10, y2: 10) 
/// let #(_, _, width, height) = bounding_box.to_ltwh_tuple(box)
/// // -> 6, 6
/// ```
pub fn to_ltwh_tuple(bounding_box: BoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, width, height)
    LTRB(left, top, right, bottom) -> #(left, top, right - left, bottom - top)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2 - x1, y2 - y1)
  }
}

/// Converts a bounding box to a tuple with the coordinate values left, top, 
/// right, bottom. Useful for working with with custom bounding box operations.
/// 
/// ## Example
/// ```gleam
/// let assert Ok(box) = bounding_box.x1y1x2y2(x1: 2, y1: 2, x2: 6, y2: 6) 
/// bounding_box.to_ltrb_tuple(box)
/// // -> #(2, 2, 6, 6)
/// ```
pub fn to_ltrb_tuple(bounding_box: BoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, left + width, top + height)
    LTRB(left, top, right, bottom) -> #(left, top, right, bottom)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2, y2)
  }
}

/// Converts a bounding box to a tuple with the coordinate values x1, y1, x2, 
/// y2. Useful for working with with custom bounding box operations.
/// 
/// ## Example
/// ```gleam
/// let assert Ok(box) = bounding_box.ltwh(2, 2, 4, 4) 
/// bounding_box.to_x1y1x2y2_tuple(box)
/// // -> #(2, 2, 6, 6)
/// ```
pub fn to_x1y1x2y2_tuple(bounding_box: BoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, left + width, top + height)
    LTRB(left, top, right, bottom) -> #(left, top, right, bottom)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2, y2)
  }
}

/// Shrinks a bounding box by the given amount in all dimensions. If the amount 
/// is negative, the bounding box will not be modified. If the amount to shrink 
/// is greater than the size of the bounding box, an error will be returned.
pub fn shrink(
  bounding_box: BoundingBox,
  by amount: Int,
) -> Result(BoundingBox, Nil) {
  use <- bool.guard(when: amount < 0, return: Ok(bounding_box))

  let #(_, _, width, height) = to_ltwh_tuple(bounding_box)

  use <- bool.guard(
    when: amount * 2 >= width || amount * 2 >= height,
    return: Error(Nil),
  )

  case bounding_box {
    LTWH(left, top, width, height) ->
      LTWH(
        left: left + amount,
        top: top + amount,
        width: int.max(width - amount * 2, 0),
        height: int.max(height - amount * 2, 0),
      )
    LTRB(left, top, right, bottom) ->
      LTRB(
        left: left + amount,
        top: top + amount,
        right: int.max(right - amount, 0),
        bottom: int.max(bottom - amount, 0),
      )
    X1Y1X2Y2(x1, y1, x2, y2) ->
      X1Y1X2Y2(
        x1: x1 + amount,
        y1: y1 + amount,
        x2: int.max(x2 - amount, 0),
        y2: int.max(y2 - amount, 0),
      )
  }
  |> Ok
}

/// Expands a bounding box by the given amount in all dimensions. If the amount 
/// is negative, the bounding box will not be modified.
pub fn expand(bounding_box: BoundingBox, by amount: Int) {
  use <- bool.guard(when: amount < 0, return: bounding_box)

  case bounding_box {
    LTWH(left, top, width, height) ->
      LTWH(
        left: int.max(left - amount, 0),
        top: int.max(top - amount, 0),
        width: width + amount * 2,
        height: height + amount * 2,
      )
    LTRB(left, top, right, bottom) ->
      LTRB(
        left: int.max(left - amount, 0),
        top: int.max(top - amount, 0),
        right: right + amount,
        bottom: bottom + amount,
      )
    X1Y1X2Y2(x1, y1, x2, y2) ->
      X1Y1X2Y2(
        x1: int.max(x1 - amount, 0),
        y1: int.max(y1 - amount, 0),
        x2: x2 + amount,
        y2: y2 + amount,
      )
  }
}

/// Resizes a bounding box by the given scale.
pub fn scale(bounding_box: BoundingBox, by scale: Float) {
  let #(left, top, right, bottom) = to_ltrb_tuple(bounding_box)

  LTRB(
    left: float.round(int.to_float(left) *. scale),
    top: float.round(int.to_float(top) *. scale),
    right: float.round(int.to_float(right) *. scale),
    bottom: float.round(int.to_float(bottom) *. scale),
  )
}

/// Cuts a bounding box out of another bounding box, returning a list of 
/// bounding boxes that represent the area of the original that was not cut out.
pub fn cut(
  out_of to_cut: BoundingBox,
  with cutter: BoundingBox,
) -> List(BoundingBox) {
  let #(x1, y1, w1, h1) = to_ltwh_tuple(to_cut)
  let #(x2, y2, w2, h2) = to_ltwh_tuple(cutter)

  let int_left = int.max(x1, x2)
  let int_top = int.max(y1, y2)
  let int_right = int.min(x1 + w1, x2 + w2)
  let int_bottom = int.min(y1 + h1, y2 + h2)

  use <- bool.guard(
    when: int_left >= int_right || int_top >= int_bottom,
    return: [to_cut],
  )

  let cut_pieces = [
    // Top piece
    case y1 < int_top {
      True -> Some(LTWH(left: x1, top: y1, width: w1, height: int_top - y1))
      False -> None
    },
    // Left piece
    case x1 < int_left {
      True ->
        Some(LTWH(
          left: x1,
          top: int_top,
          width: int_left - x1,
          height: int_bottom - int_top,
        ))
      False -> None
    },
    // Right piece
    case int_right < x1 + w1 {
      True ->
        Some(LTWH(
          left: int_right,
          top: int_top,
          width: x1 + w1 - int_right,
          height: int_bottom - int_top,
        ))
      False -> None
    },
    // Bottom piece
    case int_bottom < y1 + h1 {
      True ->
        Some(LTWH(
          left: x1,
          top: int_bottom,
          width: w1,
          height: y1 + h1 - int_bottom,
        ))
      False -> None
    },
  ]

  option.values(cut_pieces)
}

/// Returns the intersection of two bounding boxes. If they do not intersect,
/// `None` will be returned.
pub fn intersection(
  of box1: BoundingBox,
  with box2: BoundingBox,
) -> option.Option(BoundingBox) {
  let #(l1, t1, r1, b1) = to_ltrb_tuple(box1)
  let #(l2, t2, r2, b2) = to_ltrb_tuple(box2)

  use <- bool.guard(
    when: l1 >= l2 && t1 >= t2 && r1 <= r2 && b1 <= b2,
    return: Some(box1),
  )

  use <- bool.guard(
    when: l1 <= l2 && t1 <= t2 && r1 >= r2 && b1 >= b2,
    return: Some(box2),
  )

  let left = int.max(l1, l2)
  let top = int.max(t1, t2)
  let right = int.min(r1, r2)
  let bottom = int.min(b1, b2)

  use <- bool.guard(when: left >= right || top >= bottom, return: None)

  LTRB(left: left, top: top, right: right, bottom: bottom)
  |> Some
}

/// Fits a bounding box into another bounding box, dropping any pixels outside 
/// the dimensions of the reference bounding box.
pub fn fit(
  box: BoundingBox,
  into reference: BoundingBox,
) -> option.Option(BoundingBox) {
  let #(_, _, width, height) = to_ltwh_tuple(reference)

  let #(left, top, right, bottom) = to_ltrb_tuple(box)

  case left < width, top < height {
    True, True ->
      Some(LTRB(
        left: left,
        top: top,
        right: int.min(right, width),
        bottom: int.min(bottom, height),
      ))

    _, _ -> None
  }
}

/// Makes a bounding box relative to and fit inside another bounding box. 
/// Assuming both bounding boxes are on the same image, they are both relative
/// to 0,0 on that image. This adjusts the first bounding box so that the 
/// original coordinates are relative to the top left corner of the second 
/// bounding box instead, and then fits the adjusted bounding box into the 
/// reference bounding box.
/// 
/// This is useful when you have two bounding boxes on an image, where one
/// represents an extracted area of the original image and you want to do
/// an operation on that extracted area with the second bounding box, but the 
/// second bounding box was calculated with the coordinates of the original 
/// image.
/// 
/// ## Example
/// ```gleam
/// let assert Ok(box) = bounding_box.ltwh(left: 2, top: 2, width: 4, height: 4) 
/// let assert Ok(ref) = bounding_box.ltwh(left: 4, top: 4, width: 6, height: 6) 
/// bounding_box.make_relative(box, to: ref)
/// // -> Some(bounding_box.ltwh(left: 0, top: 0, width: 2, height: 2))
/// ```
pub fn make_relative(
  box: BoundingBox,
  to reference: BoundingBox,
) -> option.Option(BoundingBox) {
  let #(left, top, right, bottom) = to_ltrb_tuple(box)
  let #(ref_left, ref_top, _, _) = to_ltwh_tuple(reference)

  let adj_box =
    LTRB(
      left: int.max(left - ref_left, 0),
      top: int.max(top - ref_top, 0),
      right: int.max(right - ref_left, 0),
      bottom: int.max(bottom - ref_top, 0),
    )

  case adj_box {
    LTRB(0, 0, 0, 0) -> None
    _ -> fit(adj_box, into: reference)
  }
}
