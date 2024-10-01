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

  def to_bit_array(image, format) do
    Image.write_to_stream(image, format) |> Enum.into(<<>>)
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

      {:error, reason} ->
        {:error, reason}
    end
  end
end
