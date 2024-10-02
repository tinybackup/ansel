import gleam/int

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
