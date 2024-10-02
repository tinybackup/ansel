import gleam/bool
import gleam/float
import gleam/int
import gleam/option.{None, Some}

pub type FixedBoundingBox {
  LTWH(left: Int, top: Int, width: Int, height: Int)
  LTRB(left: Int, top: Int, right: Int, bottom: Int)
  X1Y1X2Y2(x1: Int, y1: Int, x2: Int, y2: Int)
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
        left: left + amount,
        top: top + amount,
        width: width - amount * 2,
        height: height - amount * 2,
      )
    LTRB(left, top, right, bottom) ->
      LTRB(
        left: left + amount,
        top: top + amount,
        right: right - amount,
        bottom: bottom - amount,
      )
    X1Y1X2Y2(x1, y1, x2, y2) ->
      X1Y1X2Y2(
        x1: x1 + amount,
        y1: y1 + amount,
        x2: x2 - amount,
        y2: y2 - amount,
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
  let #(left, top, bottom, right) = to_ltrb_tuple(bounding_box)

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
