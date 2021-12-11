defmodule Day11 do
  def run(mode) do
    start = :erlang.system_time(:microsecond)
    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-11")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, 0, %{})
  def prepare_data([], _, acc), do: acc

  def prepare_data([row | rest], y, acc),
    do: prepare_data(rest, y + 1, acc |> parse_row(row, y, 0))

  def parse_row(acc, "", _, _), do: acc

  def parse_row(acc, <<c, rest::binary>>, y, x),
    do: acc |> Map.put({x, y}, c - ?0) |> parse_row(rest, y, x + 1)

  def part1(data) do
    do_turns(data, 100, 0)
  end

  def part2(data) do
    do_turns_until_all_zero(data, 1)
  end

  def print_map(map) do
    IO.puts("")

    for y <- 0..9 do
      row = for x <- 0..9, do: map[{x, y}] |> Integer.to_string()
      IO.puts(row)
    end
  end

  def do_turns(_, 0, flash_count), do: flash_count

  def do_turns(map, turn, flash_count) do
    {flashes_this_turn, map} = do_one_turn(map)
    # print_map(map)
    do_turns(map, turn - 1, flash_count + flashes_this_turn)
  end

  def do_turns_until_all_zero(map, turn) do
    {flashes_this_turn, map} = do_one_turn(map)

    if flashes_this_turn == 100 do
      turn
    else
      do_turns_until_all_zero(map, turn + 1)
    end
  end

  def do_one_turn(map) do
    map =
      map
      |> Enum.reduce({map, []}, fn
        {coords, 9}, {map, flashcoords} -> {map |> Map.put(coords, 10), [coords | flashcoords]}
        {coords, v}, {map, fc} -> {map |> Map.put(coords, v + 1), fc}
      end)
      |> do_flashes

    map
    |> Enum.reduce({0, map}, fn
      {coords, v}, {cnt, map} when v > 9 -> {cnt + 1, map |> Map.put(coords, 0)}
      _, {cnt, map} -> {cnt, map}
    end)
  end

  def do_flashes({map, []}), do: map

  def do_flashes({map, [{x, y} | rest]}) do
    [
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x, y - 1},
      {x, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1}
    ]
    |> Enum.filter(fn c -> Map.has_key?(map, c) end)
    |> Enum.reduce({map, rest}, fn
      coord, {map, l} ->
        v = map |> Map.get(coord)

        {map |> Map.put(coord, v + 1),
         if v == 9 do
           [coord | l]
         else
           l
         end}
    end)
    |> do_flashes
  end
end

Day11.run(:test)
Day11.run(:actual)
