defmodule Aoc.Day1 do
  @moduledoc """
  Advent of Code 2025, Day 1 (https://adventofcode.com/2025/day/1)
  """

  use Aoc
  alias __MODULE__

  defstruct position: 50, zeros: 0

  @doc ~S"""
  Find the number of occurrences of the `0` position as we rotate a rotary dial
  through a series of position operations.

  The dial has values from `0` to `99`.

  ## Examples

    iex> Aoc.Day1.solution(input: ["L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82"])
    %Aoc.Day1{position: 32, zeros: 3}

  """
  def solution(opts \\ []) do
    input = Keyword.get_lazy(opts, :input, &input/0)
    state = Keyword.get_lazy(opts, :state, fn -> %Day1{} end)

    Enum.reduce(
      input,
      state,
      fn operation, %Day1{} = state ->
        case move(state, operation) do
          0 = position -> %Day1{state | position: position, zeros: state.zeros + 1}
          position -> %Day1{state | position: position}
        end
      end
    )
  end

  defp input, do: File.stream!(Application.app_dir(:aoc, "priv/inputs/day1")) |> Stream.map(&String.trim/1)

  defp move(state, "R" <> value), do: move(state, {&+/2, value})
  defp move(state, "L" <> value), do: move(state, {&-/2, value})

  defp move(state, {operation, value}) when is_binary(value),
    do: move(state, {operation, String.to_integer(value)})

  defp move(state, {operation, value}) do
    case apply(operation, [state.position, Integer.mod(value, 100)]) do
      position when position > 99 -> Enum.sum([position, -100])
      position when position < 0 -> Enum.sum([100, position])
      position -> position
    end
  end
end
