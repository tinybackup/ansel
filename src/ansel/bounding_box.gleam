pub type BoundingBox {
  LTWH(left: Int, top: Int, width: Int, height: Int)
  LTRB(left: Int, top: Int, right: Int, bottom: Int)
  X1Y1X2Y2(x1: Int, y1: Int, x2: Int, y2: Int)
}