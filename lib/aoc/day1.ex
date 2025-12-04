defmodule Aoc.Day1 do
  @moduledoc """
  Advent of Code 2025, Day 1 (https://adventofcode.com/2025/day/1)
  """

  defmodule State do
    defstruct position: 50, zeros: 0
  end

  defmodule RotationResult do
    @enforce_keys [:position, :rotations]
    defstruct position: nil, rotations: 0
  end

  use Aoc
  alias __MODULE__.{State, RotationResult}

  @doc ~S"""
  Find the number of occurrences of the `0` position as we rotate a rotary dial
  through a series of position operations.

  The dial has values from `0` to `99`.

  ## Examples

    iex> Aoc.Day1.part1(input: ["L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82"])
    %Aoc.Day1.State{position: 32, zeros: 3}

  """
  def part1(opts \\ []) do
    input = Keyword.get_lazy(opts, :input, &input/0)
    state = Keyword.get_lazy(opts, :state, fn -> %State{} end)

    Enum.reduce(
      input,
      state,
      fn operation, %State{} = state ->
        case move(state, operation) do
          %RotationResult{position: 0} = result ->
            %State{position: result.position, zeros: state.zeros + 1}

          %RotationResult{} = result ->
            %State{state | position: result.position}
        end
      end
    )
  end

  @doc """
  Find the number of occurrences of both passing and arriving at the `0` position
  while applying a series of rotation operations to the rotary dial.

  ## Examples

    iex> Aoc.Day1.part2(input: ["L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82"])
    %Aoc.Day1.State{position: 32, zeros: 6}

  """
  def part2(opts \\ []) do
    input = Keyword.get_lazy(opts, :input, &input/0)
    state = Keyword.get_lazy(opts, :state, fn -> %State{} end)

    Enum.reduce(
      input,
      state,
      fn operation, %State{} = state ->
        case move(state, operation) do
          %RotationResult{position: 0, rotations: rotations} ->
            %State{position: 0, zeros: state.zeros + rotations + 1}

          %RotationResult{position: position, rotations: rotations} ->
            %State{position: position, zeros: state.zeros + rotations}
        end
      end
    )
  end

  defp input, do: File.stream!(Application.app_dir(:aoc, "priv/inputs/day1")) |> Stream.map(&String.trim/1)

  defp move(state, "R" <> value), do: move(state, {&+/2, String.to_integer(value)})
  defp move(state, "L" <> value), do: move(state, {&-/2, String.to_integer(value)})

  defp move(%State{position: current_position}, {operation, value}) do
    # Whole rotations occur when the quantum of the operation is greater than the number of positions on the dial.
    rotations = Kernel.div(value, 100)

    # Calculate the offset within the dial
    offset = Integer.mod(value, 100)

    # Apply the offset to the current position of the dial, this will result in a
    case apply(operation, [current_position, offset]) do
      100 ->
        %RotationResult{position: 0, rotations: rotations}

      # If the position is greater than 99 then we need to wrap the value around.
      position when position > 99 ->
        %RotationResult{position: Enum.sum([position, -100]), rotations: rotations + min(current_position, 1)}

      # Likewise if the position is negative then we need to wrap it back around too.
      position when position < 0 ->
        %RotationResult{position: Enum.sum([100, position]), rotations: rotations + min(current_position, 1)}

      position ->
        %RotationResult{position: position, rotations: rotations}
    end
  end
end
