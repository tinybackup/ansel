/// Image formats supported by vips. All may not be supported by the default
/// vips binary included with this package, you may need to provide your
/// own vips binary on the host system to. See the package readme for details.
/// 
/// The `Custom` constructor allows for advanced vips save options to be
/// used, refer to the Vix package documentation for details.
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

/// A reference to a vips image instance. It is the basis for all image 
/// operations.
pub type Image
