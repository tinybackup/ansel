import gleam/bool
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import snag

pub opaque type FixedBoundingBox {
  LTWH(left: Int, top: Int, width: Int, height: Int)
  LTRB(left: Int, top: Int, right: Int, bottom: Int)
  X1Y1X2Y2(x1: Int, y1: Int, x2: Int, y2: Int)
}

pub fn ltwh(
  left left: Int,
  top top: Int,
  width width: Int,
  height height: Int,
) -> Result(FixedBoundingBox, snag.Snag) {
  case width > 0 && height > 0 && left >= 0 && top >= 0 {
    True -> Ok(LTWH(left: left, top: top, width: width, height: height))
    False -> snag.error("Impossible ltwh bounding box values passed")
  }
}

pub fn ltrb(
  left left: Int,
  top top: Int,
  right right: Int,
  bottom bottom: Int,
) -> Result(FixedBoundingBox, snag.Snag) {
  case left < right && top < bottom && left >= 0 && top >= 0 {
    True -> Ok(LTRB(left: left, top: top, right: right, bottom: bottom))
    False -> snag.error("Impossible ltrb bounding box values passed")
  }
}

pub fn x1y1x2y2(
  x1 x1: Int,
  y1 y1: Int,
  x2 x2: Int,
  y2 y2: Int,
) -> Result(FixedBoundingBox, snag.Snag) {
  case x1 < x2 && y1 < y2 && x1 >= 0 && y1 >= 0 {
    True -> Ok(X1Y1X2Y2(x1: x1, y1: y1, x2: x2, y2: y2))
    False -> snag.error("Impossible x1y1x2y2 bounding box values passed")
  }
}

pub fn to_ltwh_tuple(bounding_box: FixedBoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, width, height)
    LTRB(left, top, right, bottom) -> #(left, top, right - left, bottom - top)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2 - x1, y2 - y1)
  }
}

pub fn to_ltrb_tuple(bounding_box: FixedBoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, left + width, top + height)
    LTRB(left, top, right, bottom) -> #(left, top, right, bottom)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2, y2)
  }
}

pub fn to_x1y1x2y2_tuple(bounding_box: FixedBoundingBox) {
  case bounding_box {
    LTWH(left, top, width, height) -> #(left, top, left + width, top + height)
    LTRB(left, top, right, bottom) -> #(left, top, right, bottom)
    X1Y1X2Y2(x1, y1, x2, y2) -> #(x1, y1, x2, y2)
  }
}

pub fn shrink(bounding_box: FixedBoundingBox, by amount: Int) {
  case bounding_box {
    LTWH(left, top, width, height) ->
      LTWH(
        left: int.max(left + amount, 0),
        top: int.max(top + amount, 0),
        width: int.max(width - amount * 2, 0),
        height: int.max(height - amount * 2, 0),
      )
    LTRB(left, top, right, bottom) ->
      LTRB(
        left: int.max(left + amount, 0),
        top: int.max(top + amount, 0),
        right: int.max(right - amount, 0),
        bottom: int.max(bottom - amount, 0),
      )
    X1Y1X2Y2(x1, y1, x2, y2) ->
      X1Y1X2Y2(
        x1: int.max(x1 + amount, 0),
        y1: int.max(y1 + amount, 0),
        x2: int.max(x2 - amount, 0),
        y2: int.max(y2 - amount, 0),
      )
  }
}

pub fn expand(bounding_box: FixedBoundingBox, by amount: Int) {
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

pub fn resize_by(bounding_box: FixedBoundingBox, scale scale: Float) {
  let #(left, top, right, bottom) = to_ltrb_tuple(bounding_box)

  LTRB(
    left: float.round(int.to_float(left) *. scale),
    top: float.round(int.to_float(top) *. scale),
    right: float.round(int.to_float(right) *. scale),
    bottom: float.round(int.to_float(bottom) *. scale),
  )
}

pub fn cut(
  out_of to_cut: FixedBoundingBox,
  with cutter: FixedBoundingBox,
) -> List(FixedBoundingBox) {
  let #(cutter_top, cutter_left, cutter_width, cutter_height) =
    to_ltwh_tuple(cutter)

  let #(to_cut_top, to_cut_left, to_cut_width, to_cut_height) =
    to_ltwh_tuple(to_cut)

  let overlap = fn(a: #(Int, Int), b: #(Int, Int)) {
    #(int.max(a.0, b.0), int.min(a.1, b.1))
  }

  let x_overlap =
    overlap(#(cutter_top, cutter_top + cutter_width), #(
      to_cut_top,
      to_cut_top + to_cut_width,
    ))

  let y_overlap =
    overlap(#(cutter_left, cutter_left + cutter_height), #(
      to_cut_left,
      to_cut_left + to_cut_height,
    ))

  use <- bool.guard(
    when: x_overlap.0 >= x_overlap.1 || y_overlap.0 >= y_overlap.1,
    return: [to_cut],
  )

  let cut_pieces = [
    // Top piece
    case y_overlap.0 - to_cut_top > 0 {
      True ->
        Some(LTWH(
          left: to_cut_left,
          top: to_cut_top,
          width: to_cut_width,
          height: y_overlap.0 - to_cut_top,
        ))
      False -> None
    },
    // Left piece
    case x_overlap.0 - to_cut_left > 0 {
      True ->
        Some(LTWH(
          left: to_cut_left,
          top: y_overlap.0,
          width: x_overlap.0 - to_cut_left,
          height: y_overlap.1 - y_overlap.0,
        ))
      False -> None
    },
    // Right piece
    case to_cut_left + to_cut_width - x_overlap.1 > 0 {
      True ->
        Some(LTWH(
          left: x_overlap.1,
          top: y_overlap.0,
          width: to_cut_left + to_cut_width - x_overlap.1,
          height: y_overlap.1 - y_overlap.0,
        ))
      False -> None
    },
    // Bottom piece
    case to_cut_top + to_cut_height - y_overlap.1 > 0 {
      True ->
        Some(LTWH(
          left: to_cut_left,
          top: y_overlap.1,
          width: to_cut_width,
          height: to_cut_top + to_cut_height - y_overlap.1,
        ))
      False -> None
    },
  ]

  option.values(cut_pieces)
}

pub fn intersection(
  of box1: FixedBoundingBox,
  with box2: FixedBoundingBox,
) -> option.Option(FixedBoundingBox) {
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

  use <- bool.guard(when: left >= right && top >= bottom, return: None)

  LTRB(left: left, top: top, right: right, bottom: bottom)
  |> Some
}
