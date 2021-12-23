defmodule Day22 do
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
    "on x=-20..26,y=-36..17,z=-47..7
on x=-20..33,y=-21..23,z=-26..28
on x=-22..28,y=-29..23,z=-38..16
on x=-46..7,y=-6..46,z=-50..-1
on x=-49..1,y=-3..46,z=-24..28
on x=2..47,y=-22..22,z=-23..27
on x=-27..23,y=-28..26,z=-21..29
on x=-39..5,y=-6..47,z=-3..44
on x=-30..21,y=-8..43,z=-13..34
on x=-22..26,y=-27..20,z=-29..19
off x=-48..-32,y=26..41,z=-47..-37
on x=-12..35,y=6..50,z=-50..-2
off x=-48..-32,y=-32..-16,z=-15..-5
on x=-18..26,y=-33..15,z=-7..46
off x=-40..-22,y=-38..-28,z=23..41
on x=-16..35,y=-41..10,z=-47..6
off x=-32..-23,y=11..30,z=-14..3
on x=-49..-5,y=-3..45,z=-29..18
off x=18..30,y=-20..-8,z=-3..13
on x=-41..9,y=-7..43,z=-33..15
on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
on x=967..23432,y=45373..81175,z=27513..53682"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-22")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn
      "on " <> row -> {:on, split_row(row)}
      "off " <> row -> {:off, split_row(row)}
    end)
  end

  def split_row(row) do
    row
    |> String.split(",")
    |> Enum.reduce(
      {nil, nil, nil},
      fn
        "x=" <> minmax, {_, y, z} ->
          {minmax |> String.split("..") |> Enum.map(&String.to_integer/1) |> List.to_tuple(), y,
           z}

        "y=" <> minmax, {x, _, z} ->
          {x, minmax |> String.split("..") |> Enum.map(&String.to_integer/1) |> List.to_tuple(),
           z}

        "z=" <> minmax, {x, y, _} ->
          {x, y,
           minmax |> String.split("..") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
      end
    )
  end

  def part1(data) do
    data
    |> Enum.filter(fn {_, {{xmin, xmax}, {ymin, ymax}, {zmin, zmax}}} ->
      xmin >= -50 and xmax <= 50 and
        ymin >= -50 and ymax <= 50 and
        zmin >= -50 and zmax <= 50
    end)
    |> build_cube_list([])
    |> count_cubes(0)
  end

  def part2(data) do
    data
    |> build_cube_list([])
    |> count_cubes(0)
  end

  def volume({{xmin, xmax}, {ymin, ymax}, {zmin, zmax}}),
    do: (abs(xmin - xmax) + 1) * (abs(ymin - ymax) + 1) * (abs(zmin - zmax) + 1)

  def count_cubes([], n), do: n
  def count_cubes([cube | rest], n), do: count_cubes(rest, n + volume(cube))

  def build_cube_list([], list), do: list

  def build_cube_list([{:on, cube} | rest], list) do
    split_cubes = split_to_intersect([cube], list, [])
    build_cube_list(rest, split_cubes ++ list)
  end

  def build_cube_list([{:off, cube} | rest], list) do
    split_cubes = split_to_intersect(list, [cube], [])
    build_cube_list(rest, split_cubes)
  end

  def split_to_intersect(cubes, [], []), do: cubes
  def split_to_intersect([], [], done), do: done

  def split_to_intersect([], [_ | rest], done),
    do: split_to_intersect(done, rest, [])

  def split_to_intersect([cube | rest_of_cubes], [cube2 | list], done) do
    if cube |> intersects?(cube2) do
      newcubes = cube |> split_using(cube2)
      split_to_intersect(rest_of_cubes, [cube2 | list], newcubes ++ done)
    else
      split_to_intersect(rest_of_cubes, [cube2 | list], [cube | done])
    end
  end

  def intersects?(
        {{xmin, xmax}, {ymin, ymax}, {zmin, zmax}},
        {{xmin2, xmax2}, {ymin2, ymax2}, {zmin2, zmax2}}
      )
      when xmax >= xmin2 and xmin <= xmax2 and
             ymax >= ymin2 and ymin <= ymax2 and
             zmax >= zmin2 and zmin <= zmax2,
      do: true

  def intersects?(_, _), do: false

  def split_using(cube, {{xmin, xmax}, {ymin, ymax}, {zmin, zmax}} = splitter) do
    [cube]
    |> split_by(:x, xmin, [])
    |> split_by(:x, xmax, [])
    |> split_by(:y, ymin, [])
    |> split_by(:y, ymax, [])
    |> split_by(:z, zmin, [])
    |> split_by(:z, zmax, [])
    |> Enum.filter(fn c -> volume(c) != 0 and not intersects?(c, splitter) end)
    |> merge_contingous([])
    |> merge_contingous([])
  end

  def split_by([], _, _, splits), do: splits

  def split_by([{{xmin, xmax}, _, _} = cube | rest], :x, x, splits) when x > xmax or x < xmin,
    do: split_by(rest, :x, x, [cube | splits])

  def split_by([{{xmin, xmax}, y, z} | rest], :x, x, splits) when xmin < x and xmax > x,
    do:
      split_by(rest, :x, x, [
        {{xmin, x - 1}, y, z},
        {{x, x}, y, z},
        {{x + 1, xmax}, y, z} | splits
      ])

  def split_by([{{xmin, _xmax}, y, z} | rest], :x, x, splits) when xmin < x,
    do: split_by(rest, :x, x, [{{xmin, x - 1}, y, z}, {{x, x}, y, z} | splits])

  def split_by([{{_xmin, xmax}, y, z} | rest], :x, x, splits) when xmax > x,
    do: split_by(rest, :x, x, [{{x, x}, y, z}, {{x + 1, xmax}, y, z} | splits])

  def split_by([{_, {ymin, ymax}, _} = cube | rest], :y, y, splits) when y > ymax or y < ymin,
    do: split_by(rest, :y, y, [cube | splits])

  def split_by([{x, {ymin, ymax}, z} | rest], :y, y, splits) when ymin < y and ymax > y,
    do:
      split_by(rest, :y, y, [
        {x, {ymin, y - 1}, z},
        {x, {y, y}, z},
        {x, {y + 1, ymax}, z} | splits
      ])

  def split_by([{x, {ymin, _ymax}, z} | rest], :y, y, splits) when ymin < y,
    do: split_by(rest, :y, y, [{x, {ymin, y - 1}, z}, {x, {y, y}, z} | splits])

  def split_by([{x, {_ymin, ymax}, z} | rest], :y, y, splits) when ymax > y,
    do: split_by(rest, :y, y, [{x, {y, y}, z}, {x, {y + 1, ymax}, z} | splits])

  def split_by([{_, _, {zmin, zmax}} = cube | rest], :z, z, splits) when z > zmax or z < zmin,
    do: split_by(rest, :z, z, [cube | splits])

  def split_by([{x, y, {zmin, zmax}} | rest], :z, z, splits) when zmin < z and zmax > z,
    do:
      split_by(rest, :z, z, [
        {x, y, {zmin, z - 1}},
        {x, y, {z, z}},
        {x, y, {z + 1, zmax}} | splits
      ])

  def split_by([{x, y, {zmin, _zmax}} | rest], :z, z, splits) when zmin < z,
    do: split_by(rest, :z, z, [{x, y, {zmin, z - 1}}, {x, y, {z, z}} | splits])

  def split_by([{x, y, {_zmin, zmax}} | rest], :z, z, splits) when zmax > z,
    do: split_by(rest, :z, z, [{x, y, {z, z}}, {x, y, {z + 1, zmax}} | splits])

  def split_by([cube | rest], cnd, v, splits), do: split_by(rest, cnd, v, [cube | splits])

  def merge_contingous([], merged), do: merged

  def merge_contingous([cube | rest], merged) do
    {rest, merged_cube} = cube |> merge_with_rest(rest, [])
    merge_contingous(rest, [merged_cube | merged])
  end

  def merge_with_rest(cube, [], rest), do: {rest, cube}

  def merge_with_rest(cube, [cube2 | rest], newrest) do
    if can_merge?(cube, cube2) do
      merge_with_rest(cube |> merge_with(cube2), rest, newrest)
    else
      merge_with_rest(cube, rest, [cube2 | newrest])
    end
  end

  def can_merge?({x, y, {z1min, z1max}}, {x, y, {z2min, z2max}})
      when z1min - 1 == z2max or z1max + 1 == z2min,
      do: true

  def can_merge?({x, {y1min, y1max}, z}, {x, {y2min, y2max}, z})
      when y1min - 1 == y2max or y1max + 1 == y2min,
      do: true

  def can_merge?({{x1min, x1max}, y, z}, {{x2min, x2max}, y, z})
      when x1min - 1 == x2max or x1max + 1 == x2min,
      do: true

  def can_merge?(_, _), do: false

  def merge_with({x, y, {z1min, z1max}}, {x, y, {z2min, z2max}}),
    do: {x, y, {min(z1min, z2min), max(z1max, z2max)}}

  def merge_with({x, {y1min, y1max}, z}, {x, {y2min, y2max}, z}),
    do: {x, {min(y1min, y2min), max(y1max, y2max)}, z}

  def merge_with({{x1min, x1max}, y, z}, {{x2min, x2max}, y, z}),
    do: {{min(x1min, x2min), max(x1max, x2max)}, y, z}
end
