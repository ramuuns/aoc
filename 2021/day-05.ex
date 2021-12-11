defmodule Day5 do
  def run(mode) do
    data = read_input(mode)

    { 
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-05")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, [])
  def prepare_data([], acc), do: acc

  def prepare_data([row | rest], acc) do
    line = row |> parse_line()
    rest |> prepare_data([line | acc])
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn
      coords ->
        coords
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def part1(lines), do: count_lines([], lines, :part1)

  def part2(lines), do: count_lines([], lines, :all)

  def do_count([], count), do: count
  def do_count([x, x, x | rest], count), do: do_count([x, x | rest], count)
  def do_count([x, x, y | rest], count), do: do_count([y | rest], count + 1)
  def do_count([_ | rest], count), do: do_count(rest, count)

  def count_lines(points, [], _), do: points |> Enum.sort() |> do_count(0)

  def count_lines(points, [{{x, y1}, {x, y2}} | rest], mode),
    do:
      points
      |> add_line(x, y1..y2 |> Enum.to_list(), :x)
      |> count_lines(rest, mode)

  def count_lines(points, [{{x1, y}, {x2, y}} | rest], mode),
    do:
      points
      |> add_line(y, x1..x2 |> Enum.to_list(), :y)
      |> count_lines(rest, mode)

  def count_lines(points, [_ | rest], :part1), do: count_lines(points, rest, :part1)

  def count_lines(points, [{{x1, y1}, {x2, y2}} | rest], :all),
    do:
      points
      |> add_line(x1..x2 |> Enum.to_list(), y1..y2 |> Enum.to_list(), :diag)
      |> count_lines(rest, :all)

  #  have the points be represented as a single integer

  def add_line(points, _, [], _), do: points
  def add_line(points, x, [y | rest], :x), do: add_line([x * 1000 + y | points], x, rest, :x)
  def add_line(points, y, [x | rest], :y), do: add_line([x * 1000 + y | points], y, rest, :y)

  def add_line(points, [x | xrest], [y | yrest], :diag),
    do: add_line([x * 1000 + y | points], xrest, yrest, :diag)
end

