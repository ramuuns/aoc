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
     |> Enum.into(%{}), img_data |> to_image_map(%{}, 0)}
  end

  def to_image_map([], ret, _), do: ret

  def to_image_map([row | rest], ret, y),
    do: to_image_map(rest, row |> String.split("", trim: true) |> make_row(ret, y, 0), y + 1)

  def make_row([], ret, _, _), do: ret
  def make_row(["#" | rest], ret, y, x), do: make_row(rest, ret |> Map.put({x, y}, 1), y, x + 1)
  def make_row(["." | rest], ret, y, x), do: make_row(rest, ret |> Map.put({x, y}, 0), y, x + 1)

  def part1({img_ench, image}) do
    enhance(image, img_ench, 2, img_ench[0], %{0 => img_ench[0], 1 => img_ench[511]})
    |> Map.values()
    |> Enum.filter(fn v -> v == 1 end)
    |> Enum.count()
  end

  def part2({img_ench, image}) do
    enhance(image, img_ench, 50, img_ench[0], %{0 => img_ench[0], 1 => img_ench[511]})
    |> Map.values()
    |> Enum.filter(fn v -> v == 1 end)
    |> Enum.count()
  end

  def enhance(img, _, 0, _, _), do: img

  def enhance(img_map, img_ench, steps, def_idx, defaults) do
    {minx, maxx, miny, maxy} = img_map |> Map.keys() |> fin_min_max_xy(0, 0, 0, 0)

    (minx - 3)..(maxx + 3)
    |> Enum.to_list()
    |> transform_image(
      (miny - 3)..(maxy + 3) |> Enum.to_list(),
      %{},
      img_map,
      img_ench,
      defaults[def_idx]
    )
    |> enhance(img_ench, steps - 1, defaults[def_idx], defaults)
  end

  def print_image(img) do
    {minx, maxx, miny, maxy} = img |> Map.keys() |> fin_min_max_xy(0, 0, 0, 0)

    for y <- miny..maxy do
      row = for x <- minx..maxx, do: img |> Map.get({x, y}, 0)

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

  def transform_image([], _, ret, _, _, _), do: ret

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
      ret
      |> maybe_put({x, y}, get_pixel(x, y, src, ench, default))
      |> transform_line(x, rest, src, ench, default)

  def maybe_put(ret, c, 0), do: ret |> Map.put(c, 0)
  def maybe_put(ret, c, 1), do: ret |> Map.put(c, 1)

  def get_pixel(x, y, src, ench, default) do
    crd =
      [
        src |> Map.get({x - 1, y - 1}, default),
        src |> Map.get({x, y - 1}, default),
        src |> Map.get({x + 1, y - 1}, default),
        src |> Map.get({x - 1, y}, default),
        src |> Map.get({x, y}, default),
        src |> Map.get({x + 1, y}, default),
        src |> Map.get({x - 1, y + 1}, default),
        src |> Map.get({x, y + 1}, default),
        src |> Map.get({x + 1, y + 1}, default)
      ]
      |> to_number(0)

    ench |> Map.get(crd)
  end

  def to_number([], r), do: r
  def to_number([1 | rest], r), do: to_number(rest, (r <<< 1) + 1)
  def to_number([0 | rest], r), do: to_number(rest, r <<< 1)

  def fin_min_max_xy([], minx, maxx, miny, maxy), do: {minx, maxx, miny, maxy}

  def fin_min_max_xy([{x, y} | rest], minx, maxx, miny, maxy) when x < minx and y < miny,
    do: fin_min_max_xy(rest, x, maxx, y, maxy)

  def fin_min_max_xy([{x, y} | rest], minx, maxx, miny, maxy) when x > maxx and y > maxy,
    do: fin_min_max_xy(rest, minx, x, miny, y)

  def fin_min_max_xy([{x, y} | rest], minx, maxx, miny, maxy) when x > maxx and y < miny,
    do: fin_min_max_xy(rest, minx, x, y, maxy)

  def fin_min_max_xy([{x, y} | rest], minx, maxx, miny, maxy) when x < minx and y > maxy,
    do: fin_min_max_xy(rest, x, maxx, miny, y)

  def fin_min_max_xy([{x, _} | rest], minx, maxx, miny, maxy) when x > maxx,
    do: fin_min_max_xy(rest, minx, x, miny, maxy)

  def fin_min_max_xy([{x, _} | rest], minx, maxx, miny, maxy) when x < minx,
    do: fin_min_max_xy(rest, x, maxx, miny, maxy)

  def fin_min_max_xy([{_, y} | rest], minx, maxx, miny, maxy) when y < miny,
    do: fin_min_max_xy(rest, minx, maxx, y, maxy)

  def fin_min_max_xy([{_, y} | rest], minx, maxx, miny, maxy) when y > maxy,
    do: fin_min_max_xy(rest, minx, maxx, miny, y)

  def fin_min_max_xy([_ | rest], minx, maxx, miny, maxy),
    do: fin_min_max_xy(rest, minx, maxx, miny, maxy)
end
