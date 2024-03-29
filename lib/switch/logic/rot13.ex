defmodule Switch.Logic.Rot13 do
  @spec transform(String.t()) :: String.t()
  def transform(input) do
    String.replace(input, ~r/[A-Za-z]/, &transform_letter/1)
  end

  defp transform_letter(letter) do
    [char | _tail] = String.to_charlist(letter)
    rotation = if String.upcase(letter) <= "M", do: 13, else: -13

    <<char + rotation>>
  end
end
