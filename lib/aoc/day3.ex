defmodule Aoc.Day3 do
  defmodule Part1 do
    require Integer

    @doc """
    https://adventofcode.com/2025/day/3

    ## Example

      iex> Aoc.Day3.Part1.solution(input: ["987654321111111", "811111111111119", "234234234234278", "818181911112111"])
      357

    """
    def solution(opts \\ []) do
      Enum.sum_by(Keyword.get_lazy(opts, :input, &Aoc.Day3.input/0), fn bank ->
        with bank <- Enum.with_index(Integer.digits(String.to_integer(bank))),
             {first, index} = largest_in(Enum.slice(bank, 0, length(bank) - 1)),
             {last, _} = largest_in(Enum.slice(bank, index + 1, length(bank))) do
          Integer.undigits([first, last])
        end
      end)
    end

    defp largest_in(bank) do
      Enum.reduce_while(bank, {0, nil}, fn
        {9, _index} = battery, _ -> {:halt, battery}
        {digit, _index} = battery, {max, _} when digit > max -> {:cont, battery}
        _battery, max -> {:cont, max}
      end)
    end
  end

  defmodule Part2 do
    @doc """
    https://adventofcode.com/2025/day/3

    ## Example

      iex> Aoc.Day3.Part2.solution(input: ["987654321111111", "811111111111119", "234234234234278", "818181911112111"])
      3121910778619

    """
    def solution(opts \\ []) do
      Enum.sum_by(Keyword.get_lazy(opts, :input, &Aoc.Day3.input/0), fn bank ->
        with bank <- Enum.with_index(Integer.digits(String.to_integer(bank))),
             width <- length(bank),
             {digits, _} <-
               Enum.map_reduce(12..1//-1, 0, fn offset, start ->
                 {digit, index} = hd(List.keysort(Enum.slice(bank, Range.new(start, width - offset)), 0, :desc))
                 {digit, index + 1}
               end) do
          Integer.undigits(digits)
        end
      end)
    end
  end

  def input do
    Application.app_dir(:aoc, "priv/inputs/day3")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
