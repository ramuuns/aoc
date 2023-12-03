defmodule Day3 do
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
    "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-03")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    make_map(data, Map.new(), 0)
  end

  def make_map([], res, _), do: res

  def make_map([row | rest], map, y),
    do: make_map(rest, row |> String.split("", trim: true) |> make_map_row(map, y, 0), y + 1)

  def make_map_row([], map, _, _), do: map
  def make_map_row(["." | rest], map, y, x), do: make_map_row(rest, map, y, x + 1)

  def make_map_row([s | rest], map, y, x),
    do: make_map_row(rest, map |> Map.put("#{y}|#{x}", s), y, x + 1)

  def part1(data) do
    find_and_sum_adjacent_numbers(Map.keys(data), data, 0)
  end

  def part2(data) do
    find_and_sum_gear_ratios(Map.keys(data), data, 0)
  end

  def find_and_sum_adjacent_numbers([], _, sum), do: sum

  def find_and_sum_adjacent_numbers([coord | rest], map, sum),
    do: find_and_sum_adjacent_numbers(rest, map, maybe_add_to_sum(coord |> coord_to_yx, map, sum))

  def coord_to_yx(coord), do: coord |> String.split("|") |> Enum.map(&String.to_integer/1)

  def maybe_add_to_sum([y, x], map, sum) do
    if is_symbol(map["#{y}|#{x}"]) do
      find_surrounding_numbers_and_add_to_sum(y, x, map, sum)
    else
      sum
    end
  end

  def is_symbol(s) when s >= "0" and s <= "9", do: false
  def is_symbol(nil), do: false
  def is_symbol(_), do: true

  def is_digit(s) when s >= "0" and s <= "9", do: true
  def is_digit(_), do: false

  def find_surrounding_numbers_and_add_to_sum(y, x, map, sum) do
    part_numbers =
      [
        {y - 1, x - 1},
        {y - 1, x},
        {y - 1, x + 1},
        {y, x - 1},
        {y, x + 1},
        {y + 1, x - 1},
        {y + 1, x},
        {y + 1, x + 1}
      ]
      |> Enum.filter(fn {y, x} -> map["#{y}|#{x}"] |> is_digit() end)
      |> merge_adjacent([])
      |> expand_to_numbers([], map)

    sum + Enum.sum(part_numbers)
  end

  def merge_adjacent([], merged), do: merged
  def merge_adjacent([h | rest], []), do: merge_adjacent(rest, [h])

  def merge_adjacent([{y, x} | rest], [{y, p_x} | merged]) when p_x == x - 1,
    do: merge_adjacent(rest, [{y, x} | merged])

  def merge_adjacent([h | rest], merged), do: merge_adjacent(rest, [h | merged])

  def expand_to_numbers([], ret, _), do: ret

  def expand_to_numbers([{y, x} | rest], ret, map),
    do: expand_to_numbers(rest, [make_number(y, x, map) | ret], map)

  def make_number(y, x, map) do
    x = find_number_start(y, x, map)
    mk_num(y, x + 1, map, String.to_integer(map["#{y}|#{x}"]))
  end

  def mk_num(y, x, map, num) do
    if is_digit(map["#{y}|#{x}"]) do
      mk_num(y, x + 1, map, num * 10 + String.to_integer(map["#{y}|#{x}"]))
    else
      num
    end
  end

  def find_number_start(y, x, map) do
    if is_digit(map["#{y}|#{x - 1}"]) do
      find_number_start(y, x - 1, map)
    else
      x
    end
  end

  def find_and_sum_gear_ratios([], _, sum), do: sum

  def find_and_sum_gear_ratios([coord | rest], map, sum),
    do: find_and_sum_gear_ratios(rest, map, maybe_add_to_gr_sum(coord |> coord_to_yx, map, sum))

  def maybe_add_to_gr_sum([y, x], map, sum) do
    if map["#{y}|#{x}"] == "*" do
      find_surrounding_gr_numbers_and_add_to_sum(y, x, map, sum)
    else
      sum
    end
  end

  def find_surrounding_gr_numbers_and_add_to_sum(y, x, map, sum) do
    part_numbers =
      [
        {y - 1, x - 1},
        {y - 1, x},
        {y - 1, x + 1},
        {y, x - 1},
        {y, x + 1},
        {y + 1, x - 1},
        {y + 1, x},
        {y + 1, x + 1}
      ]
      |> Enum.filter(fn {y, x} -> map["#{y}|#{x}"] |> is_digit() end)
      |> merge_adjacent([])
      |> expand_to_numbers([], map)

    case part_numbers do
      [a, b] -> sum + a * b
      _ -> sum
    end
  end
end
