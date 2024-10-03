pub type ImageFormat {
  JPEG(quality: Int, keep_metadata: Bool)
  JPEG2000(quality: Int, keep_metadata: Bool)
  JPEGXL(quality: Int, keep_metadata: Bool)
  PNG
  WebP(quality: Int, keep_metadata: Bool)
  AVIF(quality: Int, keep_metadata: Bool)
  TIFF(quality: Int, keep_metadata: Bool)
  HEIC(quality: Int, keep_metadata: Bool)
  FITS
  Matlab
  PDF
  SVG
  HDR
  PPM
  CSV
  GIF
  Analyze
  NIfTI
  DeepZoom
  Custom(format: String)
}

pub type Image
