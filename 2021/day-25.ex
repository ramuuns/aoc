defmodule Day25 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-25")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, {{%{}, [], []}, 0, 0})

  def prepare_data([], data), do: data

  def prepare_data([row | rest], data),
    do: prepare_data(rest, row |> String.split("", trim: true) |> prepare_row(data, 0))

  def prepare_row([], {grid, _, y}, x), do: {grid, x, y + 1}

  def prepare_row(["." | rest], {{grid, left, down}, _, y}, x),
    do: prepare_row(rest, {{grid |> Map.put(x * 1000 + y, :free), left, down}, x, y}, x + 1)

  def prepare_row([">" | rest], {{grid, left, down}, _, y}, x),
    do:
      prepare_row(
        rest,
        {{grid |> Map.put(x * 1000 + y, :left), [{x, y} | left], down}, x, y},
        x + 1
      )

  def prepare_row(["v" | rest], {{grid, left, down}, _, y}, x),
    do:
      prepare_row(
        rest,
        {{grid |> Map.put(x * 1000 + y, :down), left, [{x, y} | down]}, x, y},
        x + 1
      )

  def part1({grid, width, height}) do
    move(grid, width, height, 1)
  end

  def part2(_) do
    0
  end

  def move({grid, left, down}, width, height, moves) do
    {newgrid, left} = move(grid, left, width, :left)
    {newgrid, down} = move(newgrid, down, height, :down)

    case newgrid do
      ^grid -> moves
      _ -> move({newgrid, left, down}, width, height, moves + 1)
    end
  end

  def move(grid, herd, modulo, mode) do
    herd
    |> Enum.sort()
    |> Enum.reduce({grid, []}, fn
      {x, y}, {newgrid, herd} ->
        if can_move(grid, mode, {x, y}, modulo) do
          {
            newgrid
            |> Map.put(x * 1000 + y, :free)
            |> Map.put(nextcoord({x, y}, mode, modulo), mode),
            [nextcoord_tuple({x, y}, mode, modulo) | herd]
          }
        else
          {newgrid, [{x, y} | herd]}
        end
    end)
  end

  def can_move(grid, mode, c, modulo), do: Map.get(grid, nextcoord(c, mode, modulo)) == :free

  def nextcoord({x, y}, :left, modulo), do: rem(x + 1, modulo) * 1000 + y
  def nextcoord({x, y}, :down, modulo), do: x * 1000 + rem(y + 1, modulo)

  def nextcoord_tuple({x, y}, :left, modulo), do: {rem(x + 1, modulo), y}
  def nextcoord_tuple({x, y}, :down, modulo), do: {x, rem(y + 1, modulo)}
end
