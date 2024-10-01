pub type Color {
  RGBA(r: Int, g: Int, b: Int, a: Int)
  RGB(r: Int, g: Int, b: Int)
  Grey
  Black
  White
}

pub fn to_bands(color: Color) -> List(Int) {
  case color {
    RGBA(r, g, b, a) -> [r, g, b, a]
    RGB(r, g, b) -> [r, g, b]
    Grey -> [128, 128, 128]
    Black -> [0, 0, 0]
    White -> [255, 255, 255]
  }
}