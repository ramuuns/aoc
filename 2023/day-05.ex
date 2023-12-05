defmodule Day5 do
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
    "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-05")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    [seeds, _ | maps] = data
    {seeds |> parse_seeds, maps |> parse_maps([], :parse_header)}
  end

  def parse_seeds("seeds: " <> seeds) do
    seeds |> String.split(~r/\s+/, trim: true) |> Enum.map(&String.to_integer/1)
  end

  def parse_maps([], res, _), do: res |> Enum.reverse()
  def parse_maps(["" | tail], res, _), do: parse_maps(tail, res, :parse_header)

  def parse_maps([header | rest], res, :parse_header) do
    [ft, _] = String.split(header, " ", trim: true)
    [from, _, to] = String.split(ft, "-", trim: true)

    parse_maps(rest, [{from, to, []} | res], :parse_numbers)
  end

  def parse_maps([nrs | rest], [{from, to, list} | res], :parse_numbers) do
    [dest, src, range] =
      nrs |> String.split(~r"\s+", trim: true) |> Enum.map(&String.to_integer/1)

    parse_maps(rest, [{from, to, [{src, dest, range} | list]} | res], :parse_numbers)
  end

  def part1(data) do
    {seeds, maps} = data
    find_min_location(seeds, maps)
  end

  def part2(data) do
    {seeds, maps} = data
    find_min_location_ranges(seeds, maps)
  end

  def find_min_location(seeds, maps) do
    seeds
    |> Enum.map(fn seed -> find_location(seed, maps) end)
    |> Enum.min()
  end

  def find_location(num, []), do: num

  def find_location(num, [{_, _, mappings} | rest]),
    do: find_location(map_number(num, mappings), rest)

  def map_number(num, []), do: num

  def map_number(num, [{src, dest, range} | _]) when num >= src and num < src + range,
    do: num - src + dest

  def map_number(num, [_ | rest]), do: map_number(num, rest)

  def find_min_location_ranges(seeds, maps) do
    seeds
    |> Enum.reduce([], fn
      i, [{num, nil} | rest] -> [{num, i} | rest]
      i, rest -> [{i, nil} | rest]
    end)
    |> Enum.map(fn seed_range -> find_location_min_range([seed_range], maps) end)
    |> Enum.min()
  end

  def find_location_min_range(ranges, []) do
    ranges |> Enum.map(fn {n, _} -> n end) |> Enum.min()
  end

  def find_location_min_range(rages, [{_, _, mappings} | rest]) do
    find_location_min_range(map_ranges(rages, mappings, []), rest)
  end

  def map_ranges([], _, res), do: res

  def map_ranges([item | rest], mappings, res) do
    map_ranges(rest, mappings, range_to_next_ranges(item, mappings) ++ res)
  end

  def range_to_next_ranges({start, range}, mappings) do
    range_to_ranges([{start, range}], mappings, mappings, [])
  end

  def range_to_ranges([], _, _, res), do: res

  def range_to_ranges([item | src_ranges], [], mappings, res),
    do: range_to_ranges(src_ranges, mappings, mappings, [item | res])

  def range_to_ranges([{start, range} | src_ranges], [{src, dst, sd_range} | _], mappings, res)
      when start >= src and start < src + sd_range and start + range < src + sd_range,
      do: range_to_ranges(src_ranges, mappings, mappings, [{start - src + dst, range} | res])

  def range_to_ranges([{start, range} | src_ranges], [{src, dst, sd_range} | _], mappings, res)
      when start >= src and start < src + sd_range,
      do:
        range_to_ranges(
          [{start + (src + sd_range - start), range - (src + sd_range - start)} | src_ranges],
          mappings,
          mappings,
          [
            {start - src + dst, src + sd_range - start} | res
          ]
        )

  def range_to_ranges([{start, range} | src_ranges], [{src, dst, sd_range} | _], mappings, res)
      when src > start and start + range > src and start + range > src + sd_range,
      do:
        range_to_ranges(
          [{start, src - start}, {src + sd_range, start + range - (src + sd_range)} | src_ranges],
          mappings,
          mappings,
          [{dst, sd_range} | res]
        )

  def range_to_ranges([{start, range} | src_ranges], [{src, dst, _} | _], mappings, res)
      when src > start and start + range > src,
      do:
        range_to_ranges([{start, src - start} | src_ranges], mappings, mappings, [
          {dst, range - (src - start)} | res
        ])

  def range_to_ranges(source, [_ | rest], mappings, res),
    do: range_to_ranges(source, rest, mappings, res)
end
