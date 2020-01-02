defmodule MorseCodeBlinky do
  @moduledoc """
  Documentation for MorseCodeBlinky.
  """

  alias MorseCodeBlinky.Queue

  @doc """
  blink the morse code for a string.

  ## Examples

      iex> MorseCodeBlinky.hello
      :world

  """
  def encode(string) do
    Queue.encode(string)
  end
end
