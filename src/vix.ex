defmodule Ansel do
  alias Vix.Vips.{Image, Operation}

  def from_bit_array(bin) do
    with {:ok, %Image{} = img} <- Image.new_from_buffer(bin) do
      {:ok, img}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def write_to_file(img, path) do
    save_path = Path.expand(path)

    case Image.write_to_file(img, save_path) do
      :ok -> {:ok, nil}
      {:error, reason} -> {:error, reason}
    end
  end

  # Image.write_to_buffer only supports png, jpg, and tiff formats so
  # it is not very useful to us :/
  def to_bit_array(image, format) do
    case Image.write_to_buffer(image, format) do
      {:ok, binary} -> {:ok, binary}
      {:error, reason} -> {:error, reason}
    end
  end

  def composite_over(base_image, overlay_image, l, t) do
    Operation.composite2(base_image, overlay_image, :VIPS_BLEND_MODE_OVER, x: l, y: t)
  end

  def extract_area(image, x, y, w, h) do
    Operation.extract_area(image, x, y, w, h)
  end

  def new_image(height, width, background) do
    case Operation.black(height, width, bands: 3) do
      {:ok, img} ->
        Image.new_from_image(img, background)
        # Operation.add(img,)
        # # Operation.linear(img, [1.0, 1.0, 1.0], [125.0, 1.0, 28.0])
        # Operation.embed(img, 0, 0, 200, 200,
        #   backgound: [240.0, 28.0, 128.0],
        #   # extend: :VIPS_EXTEND_BACKGROUND
        # )

      {:error, reason} ->
        {:error, reason}
    end
  end
end
