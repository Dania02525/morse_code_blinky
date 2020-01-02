defmodule MorseCodeBlinkyTest do
  use ExUnit.Case
  doctest MorseCodeBlinky

  test "greets the world" do
    assert MorseCodeBlinky.hello() == :world
  end
end
