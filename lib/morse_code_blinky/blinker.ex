defmodule MorseCodeBlinky.Blinker do
  alias Nerves.Leds
  require Logger

  @morse_map %{
    "A" => [:short, :long],
    "B" => [:long, :short, :short, :short],
    "C" => [:long, :short, :long, :short],
    "D" => [:long, :short, :short],
    "E" => [:short],
    "F" => [:short, :short, :long, :short],
    "G" => [:long, :long, :short],
    "H" => [:short, :short, :short, :short],
    "I" => [:short, :short],
    "J" => [:short, :long, :long, :long],
    "K" => [:long, :short, :long],
    "L" => [:short, :long, :short, :short],
    "M" => [:long, :long],
    "N" => [:long, :short],
    "O" => [:long, :long, :long],
    "P" => [:short, :long, :long, :short],
    "Q" => [:long, :long, :short, :long],
    "R" => [:short, :long, :short],
    "S" => [:short, :short, :short],
    "T" => [:long],
    "U" => [:short, :short, :long],
    "V" => [:short, :short, :short, :long],
    "W" => [:short, :long, :long],
    "X" => [:long, :short, :short, :long],
    "Y" => [:long, :short, :long, :long],
    "Z" => [:long, :long, :short, :short]
  }

  @begin_prosign [:long, :short, :long, :short, :long]
  @end_prosign [:short, :long, :short, :long, :short]

  @short_duration 100
  @long_duration 300
  @part_gap_duration 50
  @char_gap_duration 100
  @word_gap_duration 300

  @signal_led :green # change this if you don't have it in your config/<target>.exs

  def blink!(string) do
    content =
      string
      |> String.upcase
      |> String.split
      |> Enum.map(&word_to_durations/1)
      |> Enum.intersperse({false, @word_gap_duration})

    begin_prosign()
    |> Kernel.++([{false, @word_gap_duration}])
    |> Enum.concat(content)
    |> Kernel.++([{false, @word_gap_duration}])
    |> Enum.concat(end_prosign())
    |> List.flatten
    |> log_segments()
    |> Enum.each(&do_blink/1)
  end

  defp begin_prosign do
    @begin_prosign
    |> Enum.map(&parts_to_durations/1)
    |> Enum.intersperse({false, @char_gap_duration})
  end

  defp end_prosign do
    @end_prosign
    |> Enum.map(&parts_to_durations/1)
    |> Enum.intersperse({false, @char_gap_duration})
  end

  defp word_to_durations(word_string) do
    word_string
    |> String.graphemes
    |> Enum.map(&grapheme_to_durations/1)
    |> Enum.intersperse({false, @char_gap_duration})
    |> List.flatten
  end

  defp grapheme_to_durations(grapheme) do
    @morse_map
    |> Map.get(grapheme)
    |> Enum.map(&parts_to_durations/1)
    |> Enum.intersperse({false, @part_gap_duration})
  end

  defp parts_to_durations(part) do
    case part do
      :long -> {true, @long_duration}
      :short -> {true, @short_duration}
    end
  end

  defp do_blink({state, duration}) do
    Leds.set([{@signal_led, state}])
    :timer.sleep(duration)
    Leds.set([{@signal_led, false}])
  end

  defp log_segments(segments) do
    pattern =
      segments
      |> Enum.map(&segment_to_string/1)
      |> Enum.join

    Logger.debug("blinking pattern: #{pattern}")

    segments
  end

  defp segment_to_string(segment) do
    case segment do
      {false, @word_gap_duration} -> " "
      {false, _} -> ""
      {true, @short_duration} -> "."
      {true, @long_duration} -> "_"
    end
  end
end
