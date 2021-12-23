defmodule Day10 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-10")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> Enum.map(fn l -> l |> String.split("", trim: true) end)
  end

  def part1(data) do
    data
    |> Task.async_stream(&score_line/1)
    |> Enum.reduce(0, fn {_, score}, sum -> sum + score end)
  end

  def part2(data) do
    sorted_resp =
      data
      |> Task.async_stream(&score_incomplete/1)
      |> Stream.filter(fn {_, n} -> n != 0 end)
      |> Stream.map(fn {_, n} -> n end)
      |> Enum.sort()

    len = sorted_resp |> length()
    sorted_resp |> Enum.at(div(len, 2))
  end

  def score_incomplete(data), do: score_line(data, [], :incomplete)
  def score_line(data), do: score_line(data, [], :error)

  def score_line([], _, :error), do: 0
  def score_line([], stack, :incomplete), do: score_stack(stack, 0)

  def score_line([c | rest], stack, mode) when c in ["(", "<", "{", "["],
    do: score_line(rest, [c | stack], mode)

  def score_line([">" | rest], ["<" | stack], mode), do: score_line(rest, stack, mode)
  def score_line([")" | rest], ["(" | stack], mode), do: score_line(rest, stack, mode)
  def score_line(["}" | rest], ["{" | stack], mode), do: score_line(rest, stack, mode)
  def score_line(["]" | rest], ["[" | stack], mode), do: score_line(rest, stack, mode)
  def score_line([")" | _], _, :error), do: 3
  def score_line(["]" | _], _, :error), do: 57
  def score_line(["}" | _], _, :error), do: 1197
  def score_line([">" | _], _, :error), do: 25137
  def score_line(_, _, :incomplete), do: 0

  def score_stack([], score), do: score
  def score_stack(["(" | rest], score), do: score_stack(rest, score * 5 + 1)
  def score_stack(["[" | rest], score), do: score_stack(rest, score * 5 + 2)
  def score_stack(["{" | rest], score), do: score_stack(rest, score * 5 + 3)
  def score_stack(["<" | rest], score), do: score_stack(rest, score * 5 + 4)
end
