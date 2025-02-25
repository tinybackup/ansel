defmodule Ansel do
  alias Vix.Vips.{Image, Operation}

  def read(path) do
    Path.expand(path) |> Image.new_from_file()
  end

  def write_to_file(img, path) do
    save_path = Path.expand(path)

    case Image.write_to_file(img, save_path) do
      :ok -> {:ok, nil}
      {:error, reason} -> {:error, reason}
    end
  end

  def to_bit_array(image, format) do
    Image.write_to_stream(image, format) |> Enum.into(<<>>)
  end

  def to_rgb_list(image) do
    Image.to_list(image)
  end

  def from_binary(binary, height, width) do
    Image.new_from_binary(binary, height, width, 3, :VIPS_FORMAT_UCHAR)
  end

  def composite_over(base_image, overlay_image, l, t) do
    Operation.composite2(base_image, overlay_image, :VIPS_BLEND_MODE_OVER, x: l, y: t)
  end

  def new_image(width, height, background) do
    # This is a 1x1 PNG file bit array
    png =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8,
        2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 9, 112, 72, 89, 115, 0, 0, 3, 232, 0, 0, 3, 232,
        1, 181, 123, 82, 107, 0, 0, 0, 180, 101, 88, 73, 102, 73, 73, 42, 0, 8, 0, 0, 0, 6, 0, 18,
        1, 3, 0, 1, 0, 0, 0, 1, 0, 0, 0, 26, 1, 5, 0, 1, 0, 0, 0, 86, 0, 0, 0, 27, 1, 5, 0, 1, 0,
        0, 0, 94, 0, 0, 0, 40, 1, 3, 0, 1, 0, 0, 0, 2, 0, 0, 0, 19, 2, 3, 0, 1, 0, 0, 0, 1, 0, 0,
        0, 105, 135, 4, 0, 1, 0, 0, 0, 102, 0, 0, 0, 0, 0, 0, 0, 56, 99, 0, 0, 232, 3, 0, 0, 56,
        99, 0, 0, 232, 3, 0, 0, 6, 0, 0, 144, 7, 0, 4, 0, 0, 0, 48, 50, 49, 48, 1, 145, 7, 0, 4,
        0, 0, 0, 1, 2, 3, 0, 0, 160, 7, 0, 4, 0, 0, 0, 48, 49, 48, 48, 1, 160, 3, 0, 1, 0, 0, 0,
        255, 255, 0, 0, 2, 160, 4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 3, 160, 4, 0, 1, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 41, 65, 74, 44, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 248, 191, 254,
        51, 0, 5, 82, 2, 162, 71, 120, 246, 65, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>>

    case Operation.pngload_buffer(png) do
      {:ok, {img, _}} ->
        case Image.new_from_image(img, background) do
          {:ok, img} ->
            Operation.embed(img, 0, 0, width, height, extend: :VIPS_EXTEND_COPY)

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def round(image, radius) do
    width = Image.width(image)
    height = Image.height(image)

    svg = """
    <svg viewBox="0 0 #{width} #{height}">
      <rect
        rx="#{radius}"
        ry="#{radius}"
        x="0"
        y="0"
        width="#{width}"
        height="#{height}"
        fill="black"
      />
    </svg>
    """

    case Operation.svgload_buffer(svg) do
      {:ok, {mask, _flags}} ->
        case Operation.extract_band(mask, 3) do
          {:ok, band} ->
            Operation.bandjoin([image, band])

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def rotate90(image) do
    Operation.rot(image, :VIPS_ANGLE_D90)
  end

  def rotate180(image) do
    Operation.rot(image, :VIPS_ANGLE_D180)
  end

  def rotate270(image) do
    Operation.rot(image, :VIPS_ANGLE_D270)
  end
end
