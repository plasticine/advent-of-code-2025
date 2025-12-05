defmodule Aoc.Day2 do
  require Integer

  @doc """
  https://adventofcode.com/2025/day/2

  ## Example

    iex> Aoc.Day2.part1(input: "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124")
    1227775554

  """
  def part1(opts \\ []) do
    opts
    |> Keyword.get_lazy(:input, &input/0)
    |> String.split([",", "-"], trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.flat_map(&apply(Range, :new, &1))
    |> Stream.map(&Integer.digits/1)
    |> Stream.filter(&Integer.is_even(length(&1)))
    |> Stream.map(&Enum.chunk_every(&1, round(length(&1) / 2)))
    |> Enum.sum_by(fn
      [a, b] when a == b -> Integer.undigits(a ++ b)
      [_, _] -> 0
    end)
  end

  @doc """
  https://adventofcode.com/2025/day/2

  The clerk quickly discovers that there are still invalid IDs in the ranges in your list. Maybe the young Elf was doing
  other silly patterns as well?

  Now, an ID is invalid if it is made only of some sequence of digits repeated at least twice. So, 12341234 (1234 two
  times), 123123123 (123 three times), 1212121212 (12 five times), and 1111111 (1 seven times) are all invalid IDs.

  ## Example

    iex> Aoc.Day2.part2(input: "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124")
    4174379265

  """
  def part2(opts \\ []) do
    opts
    |> Keyword.get_lazy(:input, &input/0)
    |> String.split([",", "-"], trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.flat_map(&Range.to_list(apply(Range, :new, &1)))
    |> Stream.map(&Integer.digits(&1))
    |> Stream.flat_map(fn digits ->
      Enum.reduce_while(Stream.with_index(digits, 1), [], fn {_, index}, invalid ->
        case Enum.split(digits, index) do
          {pattern, haystack} when length(pattern) > length(haystack) ->
            {:halt, invalid}

          {pattern, haystack} ->
            haystack
            |> Enum.chunk_every(length(pattern))
            |> Enum.map(&(&1 == pattern))
            |> Enum.all?()
            |> case do
              true -> {:halt, [Integer.undigits(digits) | invalid]}
              false -> {:cont, invalid}
            end
        end
      end)
    end)
    |> Enum.sum()
  end

  defp input, do: String.trim(File.read!(Application.app_dir(:aoc, "priv/inputs/day2")))
end
