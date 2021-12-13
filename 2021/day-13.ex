defmodule Day13 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-13")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, MapSet.new(), [])
  def prepare_data([], coords, foldinstr), do: {coords, foldinstr |> Enum.reverse()}
  def prepare_data(["" | rest], coords, foldinstr), do: prepare_data(rest, coords, foldinstr)

  def prepare_data(["fold along y=" <> num | rest], coords, foldinstr),
    do: prepare_data(rest, coords, [{:y, num |> String.to_integer()} | foldinstr])

  def prepare_data(["fold along x=" <> num | rest], coords, foldinstr),
    do: prepare_data(rest, coords, [{:x, num |> String.to_integer()} | foldinstr])

  def prepare_data([coord | rest], coords, foldinstr),
    do:
      prepare_data(
        rest,
        coords
        |> MapSet.put(
          coord
          |> String.split(",", trim: true)
          |> Enum.map(&String.to_integer/1)
          |> List.to_tuple()
        ),
        foldinstr
      )

  def part1({coords, [instruction | _]}) do
    fold([instruction], coords) |> Enum.count()
  end

  def part2({coords, instructions}) do
    instructions |> fold(coords) |> print_coords
    0
  end

  def print_coords(coords) do
    {maxx, maxy} =
      coords
      |> Enum.reduce({0, 0}, fn
        {x, y}, {maxx, maxy} when maxx < x and maxy < y -> {x, y}
        {x, _}, {maxx, maxy} when maxx < x -> {x, maxy}
        {_, y}, {maxx, maxy} when maxy < y -> {maxx, y}
        _, {maxx, maxy} -> {maxx, maxy}
      end)

    0..maxy
    |> Enum.each(fn y ->
      0..maxx
      |> Enum.map(fn x ->
        if MapSet.member?(coords, {x, y}) do
          "#"
        else
          " "
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end)
  end

  def fold([], coords), do: coords

  def fold([instr | rest], coords),
    do: fold(rest, fold_one(coords |> MapSet.to_list(), instr, []))

  def fold_one([], _, folded), do: MapSet.new(folded)

  def fold_one([{_, y} = coord | rest], {:y, f}, folded) when y < f,
    do: fold_one(rest, {:y, f}, [coord | folded])

  def fold_one([{x, y} | rest], {:y, f}, folded),
    do: fold_one(rest, {:y, f}, [{x, f - (y - f)} | folded])

  def fold_one([{x, _} = coord | rest], {:x, f}, folded) when x < f,
    do: fold_one(rest, {:x, f}, [coord | folded])

  def fold_one([{x, y} | rest], {:x, f}, folded),
    do: fold_one(rest, {:x, f}, [{f - (x - f), y} | folded])
end
