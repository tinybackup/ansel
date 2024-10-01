pub type Color {
  RGBA(r: Int, g: Int, b: Int, a: Int)
  RGB(r: Int, g: Int, b: Int)
  GleamLucy
  GleamNavy
  Maroon
  DarkRed
  Brown
  Firebrick
  Crimson
  Red
  Tomato
  Coral
  IndianRed
  LightCoral
  DarkSalmon
  Salmon
  LightSalmon
  OrangeRed
  DarkOrange
  Orange
  Gold
  DarkGoldenRod
  GoldenRod
  PaleGoldenRod
  DarkKhaki
  Khaki
  Olive
  Yellow
  YellowGreen
  DarkOliveGreen
  OliveDrab
  LawnGreen
  Chartreuse
  GreenYellow
  DarkGreen
  Green
  ForestGreen
  Lime
  LimeGreen
  LightGreen
  PaleGreen
  DarkSeaGreen
  MediumSpringGreen
  SpringGreen
  SeaGreen
  MediumAquaMarine
  MediumSeaGreen
  LightSeaGreen
  DarkSlateGray
  Teal
  DarkCyan
  Aqua
  Cyan
  LightCyan
  DarkTurquoise
  Turquoise
  MediumTurquoise
  PaleTurquoise
  AquaMarine
  PowderBlue
  CadetBlue
  SteelBlue
  CornFlowerBlue
  DeepSkyBlue
  DodgerBlue
  LightBlue
  SkyBlue
  LightSkyBlue
  MidnightBlue
  Navy
  DarkBlue
  MediumBlue
  Blue
  RoyalBlue
  BlueViolet
  Indigo
  DarkSlateBlue
  SlateBlue
  MediumSlateBlue
  MediumPurple
  DarkMagenta
  DarkViolet
  DarkOrchid
  MediumOrchid
  Purple
  Thistle
  Plum
  Violet
  Magenta
  Fuchsia
  Orchid
  MediumVioletRed
  PaleVioletRed
  DeepPink
  HotPink
  LightPink
  Pink
  AntiqueWhite
  Beige
  Bisque
  BlanchedAlmond
  Wheat
  CornSilk
  LemonChiffon
  LightGoldenRodYellow
  LightYellow
  SaddleBrown
  Sienna
  Chocolate
  Peru
  SandyBrown
  BurlyWood
  Tan
  RosyBrown
  Moccasin
  NavajoWhite
  PeachPuff
  MistyRose
  LavenderBlush
  Linen
  OldLace
  PapayaWhip
  SeaShell
  MintCream
  SlateGray
  LightSlateGray
  LightSteelBlue
  Lavender
  FloralWhite
  AliceBlue
  GhostWhite
  Honeydew
  Ivory
  Azure
  Snow
  Black
  DimGray
  DimGrey
  Gray
  Grey
  DarkGray
  DarkGrey
  Silver
  LightGray
  LightGrey
  Gainsboro
  WhiteSmoke
  White
}

pub fn to_bands(color: Color) -> List(Int) {
  case color {
    RGBA(r, g, b, a) -> [r, g, b, a]
    c -> {
      let #(r, g, b) = to_rgb_tuple(c)
      [r, g, b]
    }
  }
}

pub fn to_rgb_tuple(color: Color) {
  case color {
    RGBA(r, g, b, _) -> #(r, g, b)
    RGB(r, g, b) -> #(r, g, b)
    GleamLucy -> #(255, 175, 243)
    GleamNavy -> #(41, 45, 62)
    Maroon -> #(128, 0, 0)
    DarkRed -> #(139, 0, 0)
    Brown -> #(165, 42, 42)
    Firebrick -> #(178, 34, 34)
    Crimson -> #(220, 20, 60)
    Red -> #(255, 0, 0)
    Tomato -> #(255, 99, 71)
    Coral -> #(255, 127, 80)
    IndianRed -> #(205, 92, 92)
    LightCoral -> #(240, 128, 128)
    DarkSalmon -> #(233, 150, 122)
    Salmon -> #(250, 128, 114)
    LightSalmon -> #(255, 160, 122)
    OrangeRed -> #(255, 69, 0)
    DarkOrange -> #(255, 140, 0)
    Orange -> #(255, 165, 0)
    Gold -> #(255, 215, 0)
    DarkGoldenRod -> #(184, 134, 11)
    GoldenRod -> #(218, 165, 32)
    PaleGoldenRod -> #(238, 232, 170)
    DarkKhaki -> #(189, 183, 107)
    Khaki -> #(240, 230, 140)
    Olive -> #(128, 128, 0)
    Yellow -> #(255, 255, 0)
    YellowGreen -> #(154, 205, 50)
    DarkOliveGreen -> #(85, 107, 47)
    OliveDrab -> #(107, 142, 35)
    LawnGreen -> #(124, 252, 0)
    Chartreuse -> #(127, 255, 0)
    GreenYellow -> #(173, 255, 47)
    DarkGreen -> #(0, 100, 0)
    Green -> #(0, 128, 0)
    ForestGreen -> #(34, 139, 34)
    Lime -> #(0, 255, 0)
    LimeGreen -> #(50, 205, 50)
    LightGreen -> #(144, 238, 144)
    PaleGreen -> #(152, 251, 152)
    DarkSeaGreen -> #(143, 188, 143)
    MediumSpringGreen -> #(0, 250, 154)
    SpringGreen -> #(0, 255, 127)
    SeaGreen -> #(46, 139, 87)
    MediumAquaMarine -> #(102, 205, 170)
    MediumSeaGreen -> #(60, 179, 113)
    LightSeaGreen -> #(32, 178, 170)
    DarkSlateGray -> #(47, 79, 79)
    Teal -> #(0, 128, 128)
    DarkCyan -> #(0, 139, 139)
    Aqua -> #(0, 255, 255)
    Cyan -> #(0, 255, 255)
    LightCyan -> #(224, 255, 255)
    DarkTurquoise -> #(0, 206, 209)
    Turquoise -> #(64, 224, 208)
    MediumTurquoise -> #(72, 209, 204)
    PaleTurquoise -> #(175, 238, 238)
    AquaMarine -> #(127, 255, 212)
    PowderBlue -> #(176, 224, 230)
    CadetBlue -> #(95, 158, 160)
    SteelBlue -> #(70, 130, 180)
    CornFlowerBlue -> #(100, 149, 237)
    DeepSkyBlue -> #(0, 191, 255)
    DodgerBlue -> #(30, 144, 255)
    LightBlue -> #(173, 216, 230)
    SkyBlue -> #(135, 206, 235)
    LightSkyBlue -> #(135, 206, 250)
    MidnightBlue -> #(25, 25, 112)
    Navy -> #(0, 0, 128)
    DarkBlue -> #(0, 0, 139)
    MediumBlue -> #(0, 0, 205)
    Blue -> #(0, 0, 255)
    RoyalBlue -> #(65, 105, 225)
    BlueViolet -> #(138, 43, 226)
    Indigo -> #(75, 0, 130)
    DarkSlateBlue -> #(72, 61, 139)
    SlateBlue -> #(106, 90, 205)
    MediumSlateBlue -> #(123, 104, 238)
    MediumPurple -> #(147, 112, 219)
    DarkMagenta -> #(139, 0, 139)
    DarkViolet -> #(148, 0, 211)
    DarkOrchid -> #(153, 50, 204)
    MediumOrchid -> #(186, 85, 211)
    Purple -> #(128, 0, 128)
    Thistle -> #(216, 191, 216)
    Plum -> #(221, 160, 221)
    Violet -> #(238, 130, 238)
    Magenta -> #(255, 0, 255)
    Fuchsia -> #(255, 0, 255)
    Orchid -> #(218, 112, 214)
    MediumVioletRed -> #(199, 21, 133)
    PaleVioletRed -> #(219, 112, 147)
    DeepPink -> #(255, 20, 147)
    HotPink -> #(255, 105, 180)
    LightPink -> #(255, 182, 193)
    Pink -> #(255, 192, 203)
    AntiqueWhite -> #(250, 235, 215)
    Beige -> #(245, 245, 220)
    Bisque -> #(255, 228, 196)
    BlanchedAlmond -> #(255, 235, 205)
    Wheat -> #(245, 222, 179)
    CornSilk -> #(255, 248, 220)
    LemonChiffon -> #(255, 250, 205)
    LightGoldenRodYellow -> #(250, 250, 210)
    LightYellow -> #(255, 255, 224)
    SaddleBrown -> #(139, 69, 19)
    Sienna -> #(160, 82, 45)
    Chocolate -> #(210, 105, 30)
    Peru -> #(205, 133, 63)
    SandyBrown -> #(244, 164, 96)
    BurlyWood -> #(222, 184, 135)
    Tan -> #(210, 180, 140)
    RosyBrown -> #(188, 143, 143)
    Moccasin -> #(255, 228, 181)
    NavajoWhite -> #(255, 222, 173)
    PeachPuff -> #(255, 218, 185)
    MistyRose -> #(255, 228, 225)
    LavenderBlush -> #(255, 240, 245)
    Linen -> #(250, 240, 230)
    OldLace -> #(253, 245, 230)
    PapayaWhip -> #(255, 239, 213)
    SeaShell -> #(255, 245, 238)
    MintCream -> #(245, 255, 250)
    SlateGray -> #(112, 128, 144)
    LightSlateGray -> #(119, 136, 153)
    LightSteelBlue -> #(176, 196, 222)
    Lavender -> #(230, 230, 250)
    FloralWhite -> #(255, 250, 240)
    AliceBlue -> #(240, 248, 255)
    GhostWhite -> #(248, 248, 255)
    Honeydew -> #(240, 255, 240)
    Ivory -> #(255, 255, 240)
    Azure -> #(240, 255, 255)
    Snow -> #(255, 250, 250)
    Black -> #(0, 0, 0)
    DimGray -> #(105, 105, 105)
    DimGrey -> #(105, 105, 105)
    Gray -> #(128, 128, 128)
    Grey -> #(128, 128, 128)
    DarkGray -> #(169, 169, 169)
    DarkGrey -> #(169, 169, 169)
    Silver -> #(192, 192, 192)
    LightGray -> #(211, 211, 211)
    LightGrey -> #(211, 211, 211)
    Gainsboro -> #(220, 220, 220)
    WhiteSmoke -> #(245, 245, 245)
    White -> #(255, 255, 255)
  }
}

pub fn to_rgba_tuple(color: Color) {
  case color {
    RGBA(r, g, b, a) -> #(r, g, b, a)
    c -> {
      let #(r, g, b) = to_rgb_tuple(c)
      #(r, g, b, 255)
    }
  }
}

pub fn add_alpha_band(color: Color, alpha: Int) -> Color {
  let #(r, g, b) = to_rgb_tuple(color)
  RGBA(r, g, b, alpha)
}
