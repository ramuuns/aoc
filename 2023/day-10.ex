defmodule Day10 do
  def run(mode) do
    data = read_input(mode, 1)
    data2 = read_input(mode, 2)

    [{1, data}, {2, data2}]
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

  def read_input(:test, 1) do
    "7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:test, 2) do
    "..........
.S------7.
.|F----7|.
FJ|OOOO|L7
L7|OOOO|FJ
FJL-7F-JL7
L7II||IIFJ
.L--JL--J.
.........."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual, _) do
    File.stream!("input-10")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    {start, map, _} =
      data
      |> Enum.reduce(
        {nil, %{}, 0},
        fn row, {s, map, y} ->
          {s, map, _, _} =
            row
            |> String.split("", trim: true)
            |> Enum.reduce(
              {s, map, y, 0},
              fn
                "S", {_, map, y, x} -> {{y, x}, map |> Map.put({y, x}, "S"), y, x + 1}
                c, {s, map, y, x} -> {s, map |> Map.put({y, x}, c), y, x + 1}
              end
            )

          {s, map, y + 1}
        end
      )

    the_grid_as_lists = data |> Enum.map(fn s -> s |> String.split("", trim: true) end)
    {start, map, the_grid_as_lists}
  end

  def part1({start, map, _}) do
    [one, two] = find_neighbors(start, map)
    {size, _} = find_furthest(one, two, map, MapSet.new([start]), 1)
    size
  end

  def find_neighbors({y, x}, map) do
    [{y - 1, x}, {y, x + 1}, {y + 1, x}, {y, x - 1}]
    |> Enum.filter(fn pos ->
      pipe = Map.get(map, pos)
      connects({y, x}, pos, pipe, map |> Map.get({y, x}))
    end)
  end

  def find_furthest(a, a, _, seen, len), do: {len, seen |> MapSet.put(a)}

  def find_furthest(p1, p2, map, seen, len) do
    [n1] = find_neighbors(p1, map) |> Enum.filter(fn n -> not MapSet.member?(seen, n) end)
    [n2] = find_neighbors(p2, map) |> Enum.filter(fn n -> not MapSet.member?(seen, n) end)
    find_furthest(n1, n2, map, seen |> MapSet.put(p1) |> MapSet.put(p2), len + 1)
  end

  def connects({y1, x}, {y2, x}, "|", c)
      when c == "S" or
             c == "|" or
             (c == "J" and y2 < y1) or
             (c == "F" and y2 > y1) or
             (c == "L" and y2 < y1) or
             (c == "7" and y2 > y1),
      do: true

  def connects({y, x1}, {y, x2}, "-", c)
      when c == "S" or
             c == "-" or
             (c == "J" and x2 < x1) or
             (c == "7" and x2 < x1) or
             (c == "F" and x2 > x1) or
             (c == "L" and x2 > x1),
      do: true

  def connects({y1, x}, {y2, x}, "L", c)
      when y1 < y2 and (c == "S" or c == "|" or c == "7" or c == "F"),
      do: true

  def connects({y, x1}, {y, x2}, "L", c)
      when x2 < x1 and (c == "S" or c == "-" or c == "7" or c == "J"),
      do: true

  def connects({y1, x}, {y2, x}, "J", c)
      when y1 < y2 and (c == "S" or c == "|" or c == "7" or c == "F"),
      do: true

  def connects({y, x1}, {y, x2}, "J", c)
      when x2 > x1 and (c == "S" or c == "-" or c == "F" or c == "L"),
      do: true

  def connects({y1, x}, {y2, x}, "7", c)
      when y1 > y2 and (c == "S" or c == "|" or c == "L" or c == "J"),
      do: true

  def connects({y, x1}, {y, x2}, "7", c)
      when x2 > x1 and (c == "S" or c == "-" or c == "F" or c == "L"),
      do: true

  def connects({y1, x}, {y2, x}, "F", c)
      when y1 > y2 and (c == "S" or c == "|" or c == "L" or c == "J"),
      do: true

  def connects({y, x1}, {y, x2}, "F", c)
      when x2 < x1 and (c == "S" or c == "-" or c == "7" or c == "J"),
      do: true

  def connects(_, _, "S", _), do: true
  def connects(_, _, _, _), do: false

  def part2({start, map, grid}) do
    [one, two] = find_neighbors(start, map)
    derived_s = derive_s(start, one, two)
    {_, pipe} = find_furthest(one, two, map, MapSet.new([start]), 1)

    cnt =
      grid
      |> Enum.with_index(fn row, y ->
        case start do
          {^y, _} ->
            {y,
             row
             |> Enum.map(fn
               "S" -> derived_s
               el -> el
             end)}

          _ ->
            {y, row}
        end
      end)
      |> Enum.reduce(0, fn {y, row}, inside_count ->
        count_row_inside(row, inside_count, pipe, [], false, y, 0)
      end)

    cnt
  end

  def count_row_inside([], cnt, _, _, _, _, _), do: cnt

  def count_row_inside(["|" | rest], cnt, pipe, stack, is_inside, y, x) do
    if MapSet.member?(pipe, {y, x}) do
      count_row_inside(rest, cnt, pipe, stack, not is_inside, y, x + 1)
    else
      count_row_inside(
        rest,
        if is_inside do
          cnt + 1
        else
          cnt
        end,
        pipe,
        stack,
        is_inside,
        y,
        x + 1
      )
    end
  end

  def count_row_inside(["-" | rest], cnt, pipe, stack, is_inside, y, x) do
    if MapSet.member?(pipe, {y, x}) do
      count_row_inside(rest, cnt, pipe, stack, is_inside, y, x + 1)
    else
      count_row_inside(
        rest,
        if is_inside do
          cnt + 1
        else
          cnt
        end,
        pipe,
        stack,
        is_inside,
        y,
        x + 1
      )
    end
  end

  def count_row_inside([h | rest], cnt, pipe, stack, is_inside, y, x) when h == "F" or h == "L" do
    if MapSet.member?(pipe, {y, x}) do
      count_row_inside(rest, cnt, pipe, [h | stack], is_inside, y, x + 1)
    else
      count_row_inside(
        rest,
        if is_inside do
          cnt + 1
        else
          cnt
        end,
        pipe,
        stack,
        is_inside,
        y,
        x + 1
      )
    end
  end

  def count_row_inside([h | rest], cnt, pipe, [c | stack], is_inside, y, x)
      when (c == "L" or c == "F") and (h == "7" or h == "J") do
    if MapSet.member?(pipe, {y, x}) do
      count_row_inside(
        rest,
        cnt,
        pipe,
        stack,
        if (c == "F" and h == "7") or (c == "L" and h == "J") do
          is_inside
        else
          not is_inside
        end,
        y,
        x + 1
      )
    else
      count_row_inside(
        rest,
        if is_inside do
          cnt + 1
        else
          cnt
        end,
        pipe,
        [c | stack],
        is_inside,
        y,
        x + 1
      )
    end
  end

  def count_row_inside([_ | rest], cnt, pipe, stack, is_inside, y, x) do
    count_row_inside(
      rest,
      if is_inside do
        cnt + 1
      else
        cnt
      end,
      pipe,
      stack,
      is_inside,
      y,
      x + 1
    )
  end

  def part2_original({start, map, _}) do
    [one, two] = find_neighbors(start, map)
    derived_s = derive_s(start, one, two)
    map = Map.put(map, start, derived_s)
    {_, pipe} = find_furthest(one, two, map, MapSet.new([start]), 1)

    points = map |> Map.keys() |> Enum.filter(fn p -> not MapSet.member?(pipe, p) end)

    flood_areas(points, pipe, map, MapSet.new(), [])
    |> Enum.filter(fn {_, is_outside} -> not is_outside end)
    |> Enum.reduce(MapSet.new(), fn {list, _}, inside ->
      inside |> MapSet.union(MapSet.new(list))
    end)
    |> Enum.count()
  end

  def flood_areas([], _, _, _, ret), do: ret

  def flood_areas([p | rest], pipe, map, seen, ret) do
    if MapSet.member?(seen, p) or MapSet.member?(pipe, p) do
      flood_areas(rest, pipe, map, seen, ret)
    else
      {area, seen} = flood_area([p], pipe, map, seen, [p], false)
      # print_seen_area(area, map, pipe)
      flood_areas(rest, pipe, map, seen, [area | ret])
    end
  end

  def flood_area([], _, _, seen, area, is_outside), do: {{area, is_outside}, seen}

  def flood_area([{y, x} = p | rest], pipe, map, seen, area, is_outside) do
    if MapSet.member?(seen, p) do
      flood_area(rest, pipe, map, seen, area, is_outside)
    else
      neighbors =
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
        |> Enum.filter(fn n -> not MapSet.member?(seen, n) end)

      within_map_neighbors = neighbors |> Enum.filter(fn n -> Map.has_key?(map, n) end)
      is_outside = is_outside or Enum.count(neighbors) > Enum.count(within_map_neighbors)

      non_pipe_neighbors =
        within_map_neighbors |> Enum.filter(fn n -> not MapSet.member?(pipe, n) end)

      pipe_neighbors =
        within_map_neighbors
        |> Enum.filter(fn {py, px} -> not (py != y and px != x) end)
        |> Enum.filter(fn n -> MapSet.member?(pipe, n) end)
        |> Enum.reduce([], fn {py, px}, pipe_points ->
          {ny, nx} = {y - py, x - px}
          segment = Map.get(map, {py, px})

          case segment do
            "|" ->
              [{py, px, ny, nx} | pipe_points]

            "-" ->
              [{py, px, ny, nx} | pipe_points]

            _ ->
              {ny2, nx2} = normal({ny, nx}, {py, px}, map)
              [{py, px, ny, nx}, {py, px, ny2, nx2} | pipe_points]
          end
        end)
        |> Enum.filter(fn {py, px, ny, nx} ->
          valid_normal({py, px}, {ny, nx}, map)
        end)
        |> Enum.filter(fn p -> not MapSet.member?(seen, p) end)

      flood_area(
        non_pipe_neighbors ++ pipe_neighbors ++ rest,
        pipe,
        map,
        seen |> MapSet.put(p),
        [p | area],
        is_outside
      )
    end
  end

  def flood_area([{y, x, dy, dx} = p | rest], pipe, map, seen, area, is_outside) do
    if MapSet.member?(seen, p) do
      flood_area(rest, pipe, map, seen, area, is_outside)
    else
      seen = seen |> MapSet.put(p)
      normal_neighbor = {y + dy, x + dx}

      neighbors =
        find_neighbors({y, x}, map)
        |> Enum.filter(fn {ny, nx} -> not (ny + dy == y and nx + dx == x) end)

      neighbors =
        if MapSet.member?(pipe, normal_neighbor) do
          neighbors
        else
          [normal_neighbor | neighbors]
        end
        |> Enum.filter(fn n -> not MapSet.member?(seen, n) end)

      within_map_neighbors = neighbors |> Enum.filter(fn n -> Map.has_key?(map, n) end)
      is_outside = is_outside or Enum.count(neighbors) > Enum.count(within_map_neighbors)

      non_pipe_neighbors =
        within_map_neighbors |> Enum.filter(fn n -> not MapSet.member?(pipe, n) end)

      pipe_neighbors =
        within_map_neighbors
        |> Enum.filter(fn n -> MapSet.member?(pipe, n) end)
        |> Enum.map(fn {py, px} ->
          {ny, nx} = normal({dy, dx}, {py, px}, {y, x}, map)
          {py, px, ny, nx}
        end)
        |> Enum.filter(fn {py, px, ny, nx} ->
          valid_normal({py, px}, {ny, nx}, map)
        end)
        |> Enum.filter(fn p -> not MapSet.member?(seen, p) end)

      flood_area(
        non_pipe_neighbors ++ pipe_neighbors ++ rest,
        pipe,
        map,
        seen,
        area,
        is_outside
      )
    end
  end

  def valid_normal(p, {dy, dx}, map) do
    segment = Map.get(map, p)

    case segment do
      "-" -> dx == 0
      "|" -> dy == 0
      _ -> true
    end
  end

  def print_seen({py, px}, seen, map, pipe) do
    0..20
    |> Enum.map(fn y ->
      0..20
      |> Enum.map(fn x ->
        cond do
          y == py and x == px -> "X"
          MapSet.member?(pipe, {y, x}) -> Map.get(map, {y, x})
          MapSet.member?(seen, {y, x}) -> "O"
          true -> "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print_seen({py, px, dy, dx}, seen, map, pipe) do
    0..20
    |> Enum.map(fn y ->
      0..20
      |> Enum.map(fn x ->
        cond do
          y == py + dy and x == px + dx -> "N"
          y == py and x == px -> "X"
          MapSet.member?(pipe, {y, x}) -> Map.get(map, {y, x})
          MapSet.member?(seen, {y, x}) -> "O"
          true -> "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print_seen_area({area, is_outside}, map, pipe) do
    seen_area = MapSet.new(area)

    0..140
    |> Enum.map(fn y ->
      0..140
      |> Enum.map(fn x ->
        cond do
          MapSet.member?(seen_area, {y, x}) ->
            if is_outside do
              "O"
            else
              "I"
            end

          MapSet.member?(pipe, {y, x}) ->
            Map.get(map, {y, x})

          true ->
            "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print_path(path, map, the_outsides) do
    0..140
    |> Enum.map(fn y ->
      0..140
      |> Enum.map(fn x ->
        cond do
          MapSet.member?(the_outsides, {y, x}) -> "O"
          MapSet.member?(path, {y, x}) -> Map.get(map, {y, x})
          true -> "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def normal({dy, dx}, p, prev, map) do
    curve = Map.get(map, p)

    case curve do
      "|" ->
        {dy, dx}

      "-" ->
        {dy, dx}

      _ ->
        prev_curve = Map.get(map, prev)
        {ny, nx} = normal({dy, dx}, p, map)

        cond do
          (prev_curve == "J" or prev_curve == "|") and curve == "7" and dx == 0 ->
            {-ny, -nx}

          (prev_curve == "7" or prev_curve == "-") and curve == "F" and dy == 0 ->
            {-ny, -nx}

          (prev_curve == "F" or prev_curve == "|") and curve == "L" and dx == 0 ->
            {-ny, -nx}

          (prev_curve == "L" or prev_curve == "-") and curve == "J" and dy == 0 ->
            {-ny, -nx}

          (prev_curve == "J" or prev_curve == "-") and curve == "L" and dy == 0 ->
            {-ny, -nx}

          (prev_curve == "7" or prev_curve == "|") and curve == "J" and dx == 0 ->
            {-ny, -nx}

          (prev_curve == "F" or prev_curve == "-") and curve == "7" and dy == 0 ->
            {-ny, -nx}

          (prev_curve == "L" or prev_curve == "|") and curve == "F" and dx == 0 ->
            {-ny, -nx}

          true ->
            {ny, nx}
        end
    end
  end

  def normal({dy, dx}, p, map) do
    curve = Map.get(map, p)

    case curve do
      "|" ->
        {dy, dx}

      "-" ->
        {dy, dx}

      "L" ->
        case {dy, dx} do
          {1, 0} -> {0, -1}
          {0, -1} -> {1, 0}
          {-1, 0} -> {0, 1}
          {0, 1} -> {-1, 0}
        end

      "F" ->
        case {dy, dx} do
          {1, 0} -> {0, 1}
          {0, 1} -> {1, 0}
          {-1, 0} -> {0, -1}
          {0, -1} -> {-1, 0}
        end

      "7" ->
        case {dy, dx} do
          {1, 0} -> {0, -1}
          {0, -1} -> {1, 0}
          {-1, 0} -> {0, 1}
          {0, 1} -> {-1, 0}
        end

      "J" ->
        case {dy, dx} do
          {1, 0} -> {0, 1}
          {0, 1} -> {1, 0}
          {-1, 0} -> {0, -1}
          {0, -1} -> {-1, 0}
        end
    end
  end

  def derive_s({y, x}, {y1, x1}, {y2, x2}) do
    cond do
      x1 == x2 -> "|"
      y1 == y2 -> "-"
      y1 == y and y2 == y - 1 and x2 == x and x1 == x + 1 -> "L"
      y2 == y and y1 == y - 1 and x1 == x and x2 == x + 1 -> "L"
      y1 == y and y2 == y + 1 and x1 == x + 1 and x2 == x -> "F"
      y2 == y and y1 == y + 1 and x2 == x + 1 and x1 == x -> "F"
      y1 == y and y2 == y - 1 and x2 == x and x1 == x - 1 -> "J"
      y2 == y and y1 == y - 1 and x1 == x and x2 == x - 1 -> "J"
      y1 == y and y2 == y + 1 and x1 == x - 1 and x2 == x -> "7"
      y2 == y and y1 == y + 1 and x2 == x - 1 and x1 == x -> "7"
    end
  end
end
