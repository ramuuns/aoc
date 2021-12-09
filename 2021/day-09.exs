defmodule Day9 do
  def run(mode) do
    start = :erlang.system_time(:microsecond)
    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "2199943210
3987894921
9856789892
8767896789
9899965678"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-09")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, 0, %{})

  def prepare_data([], _, acc), do: acc

  def prepare_data([row | rest], y, acc),
    do: prepare_data(rest, y + 1, acc |> prepare_row(row |> String.split("", trim: true), y, 0))

  def prepare_row(acc, [], _, _), do: acc

  def prepare_row(acc, [n | rest], y, x),
    do: acc |> Map.put({x, y}, String.to_integer(n)) |> prepare_row(rest, y, x + 1)

  def part1(data) do
    data
    |> Enum.reduce(0, fn point, acc -> acc + risk_level_if_min(point, data) end)
  end

  def part2(data) do
    data
    |> Map.to_list()
    |> list_of_basin_sizes([], data, %{})
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(1, fn n, acc -> acc * n end)
  end

  def risk_level_if_min({_, 9}, _), do: 0

  def risk_level_if_min({{x, y}, n}, map) do
    min_neighbor =
      [
        Map.get(map, {x - 1, y}, 9),
        Map.get(map, {x + 1, y}, 9),
        Map.get(map, {x, y - 1}, 9),
        Map.get(map, {x, y + 1}, 9)
      ]
      |> Enum.min()

    if n < min_neighbor do
      1 + n
    else
      0
    end
  end

  def list_of_basin_sizes([], ret, _, _), do: ret

  def list_of_basin_sizes([{_, 9} | points], ret, map, seen),
    do: list_of_basin_sizes(points, ret, map, seen)

  def list_of_basin_sizes([{point, _} | points], ret, map, seen) when is_map_key(seen, point),
    do: list_of_basin_sizes(points, ret, map, seen)

  def list_of_basin_sizes([{{x, y} = point, _} | points], ret, map, seen) do
    {seen, basin_size} =
      flood_basin(
        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}],
        map,
        seen |> Map.put(point, 1),
        1
      )

    list_of_basin_sizes(points, [basin_size | ret], map, seen)
  end

  def flood_basin([], _, seen, size), do: {seen, size}

  def flood_basin([point | next], map, seen, size) when is_map_key(seen, point),
    do: flood_basin(next, map, seen, size)

  def flood_basin([{x, y} = point | next], map, seen, size) do
    if Map.get(map, point, 9) == 9 do
      flood_basin(next, map, seen, size)
    else
      flood_basin(
        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1} | next],
        map,
        seen |> Map.put(point, 1),
        size + 1
      )
    end
  end
end

Day9.run(:test)
Day9.run(:actual)
