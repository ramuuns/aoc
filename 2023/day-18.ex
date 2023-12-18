defmodule Day18 do
  def run(mode) do
    data = read_input(mode)

    [{1, data}, {2, data}]
    |> Task.async_stream(
      fn
        {1, data} -> {1, data |> part1}
        {2, data} -> {2, data |> part2}
      end,
      timeout: :infinity
    )
    |> Enum.reduce({0, 0}, fn
      {_, {1, res}}, {_, p2} -> {res, p2}
      {_, {2, res}}, {p1, _} -> {p1, res}
    end)
  end

  def read_input(:test) do
    "R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-18")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> Enum.map(&parse_instr/1)
  end

  def parse_instr(instr) do
    [dir, num, color] = instr |> String.split(" ", trim: true)
    <<dir::utf8>> = dir
    num = num |> String.to_integer()
    color = hexcode_to_rgb(color)
    {dir, num, color}
  end

  def hexcode_to_rgb(color) do
    {
      color |> String.slice(7, 1) |> String.to_integer(16) |> to_dir(),
      color |> String.slice(2, 5) |> String.to_integer(16),
      1
    }
  end

  def to_dir(0), do: ?R
  def to_dir(1), do: ?D
  def to_dir(2), do: ?L
  def to_dir(3), do: ?U

  def part1(data) do
    data
    |> dig_trenches({0, 0}, [])
    |> Enum.reverse()
    |> calc_area(0)
  end

  def dig_trenches([], _, ret), do: [{0, 0} | ret]

  def dig_trenches([{dir, amount, color} | rest], pos, ret),
    do: dig_trenches(rest, next_pos(pos, dir, amount), [pos | ret])

  def next_pos({y, x}, dir, amount) do
    {dy, dx} = decode_dir(dir)
    {y + dy * amount, x + dx * amount}
  end

  def decode_dir(?U), do: {-1, 0}
  def decode_dir(?D), do: {1, 0}
  def decode_dir(?L), do: {0, -1}
  def decode_dir(?R), do: {0, 1}

  def calc_area([_], area), do: div(area, 2) + 1
  def calc_area([a, b | rest], area), do: calc_area([b | rest], area + det(a, b))

  def det({y1, x1}, {y2, x2}), do: x1 * y2 - x2 * y1 + abs(y1 - y2) + abs(x1 - x2)

  def part2(data) do
    data
    |> Enum.map(fn {_, _, color} -> color end)
    |> dig_trenches({0, 0}, [])
    |> Enum.reverse()
    |> calc_area(0)
  end
end
