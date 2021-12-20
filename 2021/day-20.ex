defmodule Day20 do
  use Bitwise

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-20")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([ench, "" | img_data]) do
    {ench
     |> String.split("", trim: true)
     |> Enum.with_index()
     |> Enum.map(fn
       {"#", i} -> {i, 1}
       {".", i} -> {i, 0}
     end)
     |> Enum.into(%{}), img_data |> to_image_map(%{}, 0, 0)}
  end

  def to_image_map([], ret, y, x), do: {y, x, ret}

  def to_image_map([row | rest], ret, y, _) do
    {x, ret} = row |> String.split("", trim: true) |> make_row(ret, y, 0)
    to_image_map(rest, ret, y + 1, x)
  end

  def make_row([], ret, _, x), do: {x, ret}

  def make_row(["#" | rest], ret, y, x),
    do: make_row(rest, ret |> Map.put(x * 10000 + y, 1), y, x + 1)

  def make_row(["." | rest], ret, y, x),
    do: make_row(rest, ret |> Map.put(x * 10000 + y, 0), y, x + 1)

  def part1({img_ench, {y, x, image}}) do
    enhance(
      image,
      img_ench,
      2,
      img_ench[0],
      %{0 => img_ench[0], 1 => img_ench[511]},
      {0, x, 0, y}
    )
    |> Map.values()
    |> Enum.filter(fn v -> v == 1 end)
    |> Enum.count()
  end

  def part2({img_ench, {y, x, image}}) do
    enhance(
      image,
      img_ench,
      50,
      img_ench[0],
      %{0 => img_ench[0], 1 => img_ench[511]},
      {0, x, 0, y}
    )
    |> Map.values()
    |> Enum.filter(fn v -> v == 1 end)
    |> Enum.count()
  end

  def enhance(img, _, 0, _, _, _), do: img

  def enhance(img_map, img_ench, steps, def_idx, defaults, {minx, maxx, miny, maxy}) do
    (minx - 3)..(maxx + 3)
    |> Enum.to_list()
    |> transform_image(
      (miny - 3)..(maxy + 3) |> Enum.to_list(),
      [],
      img_map,
      img_ench,
      defaults[def_idx]
    )
    |> enhance(
      img_ench,
      steps - 1,
      defaults[def_idx],
      defaults,
      {minx - 1, maxx + 1, miny - 1, maxy + 1}
    )
  end

  def print_image(img, {minx, maxx, miny, maxy}) do
    {minx, maxx, miny, maxy} |> IO.inspect()

    for y <- miny..maxy do
      row = for x <- minx..maxx, do: img |> Map.get(x * 10000 + y, 0)

      row
      |> Enum.map(fn
        0 -> "."
        1 -> "#"
      end)
      |> Enum.join("")
      |> IO.puts()
    end

    img
  end

  def transform_image([], _, ret, _, _, _), do: ret |> Map.new()

  def transform_image([x | rest], y, ret, src, ench, default),
    do:
      transform_image(
        rest,
        y,
        ret |> transform_line(x, y, src, ench, default),
        src,
        ench,
        default
      )

  def transform_line(ret, _, [], _, _, _), do: ret

  def transform_line(ret, x, [y | rest], src, ench, default),
    do:
      [{x * 10000 + y, get_pixel(x, y, src, ench, default)} | ret]
      |> transform_line(x, rest, src, ench, default)

  def get_pixel(x, y, src, ench, default) do
    crd =
      256 * Map.get(src, (x - 1) * 10000 + y - 1, default) +
        128 * Map.get(src, x * 10000 + y - 1, default) +
        64 * Map.get(src, (x + 1) * 10000 + y - 1, default) +
        32 * Map.get(src, (x - 1) * 10000 + y, default) +
        16 * Map.get(src, x * 10000 + y, default) +
        8 * Map.get(src, (x + 1) * 10000 + y, default) +
        4 * Map.get(src, (x - 1) * 10000 + y + 1, default) +
        2 * Map.get(src, x * 10000 + y + 1, default) +
        Map.get(src, (x + 1) * 10000 + y + 1, default)

    ench |> Map.get(crd)
  end
end
