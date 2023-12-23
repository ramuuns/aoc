defmodule Day23 do
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
    "#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-23")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> parse_data(0, {0, 0}, {0, 0}, %{})
  end

  def parse_data([], _, start, finish, map), do: {start, finish, map}

  def parse_data([row | rest], y, start, finish, map) do
    {start, finish, map} = parse_row(row, y, 0, start, finish, map)
    parse_data(rest, y + 1, start, finish, map)
  end

  def parse_row("", _, _, start, finish, map), do: {start, finish, map}

  def parse_row("#" <> rest, y, x, start, finish, map),
    do: parse_row(rest, y, x + 1, start, finish, map)

  def parse_row("." <> rest, 0, x, {0, 0}, finish, map),
    do: parse_row(rest, 0, x + 1, {0, x}, finish, map |> Map.put({0, x}, "."))

  def parse_row("." <> rest, y, x, start, _, map),
    do: parse_row(rest, y, x + 1, start, {y, x}, map |> Map.put({y, x}, "."))

  def parse_row(<<ch::utf8, rest::binary>>, y, x, start, finish, map),
    do: parse_row(rest, y, x + 1, start, finish, map |> Map.put({y, x}, <<ch>>))

  def part1({start, finish, map}) do
    # {start, finish, map} |> IO.inspect(limit: :infinity )
    find_longest(
      [{start, 0, MapSet.new([start])}],
      %{} |> Map.put(start, 0),
      finish,
      map,
      0,
      false
    )
  end

  def find_longest([], _, _, _, max, _), do: max

  def find_longest([{finish, len, path} | rest], max_map, finish, map, max, steep)
      when len > max do
    len |> IO.inspect()
    # print_path(len, path, map)
    find_longest(rest, max_map, finish, map, len, steep)
  end

  def find_longest([{finish, _, _} | rest], max_map, finish, map, max, steep),
    do: find_longest(rest, max_map, finish, map, max, steep)

  def find_longest([{{y, x}, len, seen} | rest], max_map, finish, map, max, false) do
    next =
      [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
      |> Enum.filter(fn {dy, dx} ->
        # and Map.get(max_map, {y + dy, x + dx}, 0) < len + 1
        Map.has_key?(map, {y + dy, x + dx}) and not MapSet.member?(seen, {y + dy, x + dx})
      end)
      |> Enum.map(fn {dy, dx} ->
        case Map.get(map, {y + dy, x + dx}) do
          "." ->
            {{y + dy, x + dx}, len + 1, seen |> MapSet.put({y + dy, x + dx})}

          ">" ->
            {{y + dy, x + dx + 1}, len + 2,
             seen |> MapSet.put({y + dy, x + dx}) |> MapSet.put({y + dy, x + dx + 1})}

          "<" ->
            {{y + dy, x + dx - 1}, len + 2,
             seen |> MapSet.put({y + dy, x + dx}) |> MapSet.put({y + dy, x + dx - 1})}

          "^" ->
            {{y + dy - 1, x + dx}, len + 2,
             seen |> MapSet.put({y + dy, x + dx}) |> MapSet.put({y + dy - 1, x + dx})}

          "v" ->
            {{y + dy + 1, x + dx}, len + 2,
             seen |> MapSet.put({y + dy, x + dx}) |> MapSet.put({y + dy + 1, x + dx})}
        end
      end)
      |> Enum.filter(fn
        {{^y, ^x}, _, _} -> false
        _ -> true
      end)

    # max_map = next |> Enum.reduce(max_map, fn { pos, len, _ }, max_map -> max_map |> Map.put(pos, len) end)
    # {y,x,len, next} |> IO.inspect()

    find_longest(next ++ rest, max_map, finish, map, max, false)
  end

  def find_longest([{{y, x}, len, seen} | rest], dead_ends, finish, map, max, true) do
    next =
      [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
      |> Enum.filter(fn {dy, dx} ->
        Map.has_key?(map, {y + dy, x + dx}) and not MapSet.member?(seen, {y + dy, x + dx}) and
          (not Map.has_key?(dead_ends, {y, x}) or
             Map.get(dead_ends, {y, x}) |> Map.get({dy, dx}))
      end)
      |> Enum.map(fn {dy, dx} ->
        {{y + dy, x + dx}, len + 1, seen |> MapSet.put({y + dy, x + dx})}
      end)
      |> Enum.filter(fn
        {{^y, ^x}, _, _} -> false
        _ -> true
      end)

    # max_map = next |> Enum.reduce(max_map, fn { pos, len, _ }, max_map -> max_map |> Map.put(pos, len) end)
    # {y,x,len, next} |> IO.inspect()

    find_longest(next ++ rest, dead_ends, finish, map, max, true)
  end

  def find_dead_ends(map, finish) do
    intersections =
      map
      |> Map.keys()
      |> Enum.filter(fn {y, x} ->
        [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
        |> Enum.filter(fn {dy, dx} ->
          Map.has_key?(map, {y + dy, x + dx})
        end)
        |> Enum.count() > 2
      end)

    intersections
    |> Enum.reduce(
      %{},
      fn {y, x}, ret ->
        val =
          [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
          |> Enum.filter(fn {dy, dx} ->
            Map.has_key?(map, {y + dy, x + dx})
          end)
          |> Enum.reduce(
            %{},
            fn {dy, dx} = d, ret ->
              ret
              |> Map.put(
                d,
                is_reachable(
                  [{y + dy, x + dx}],
                  map,
                  MapSet.new([{y, x}, {y + dy, x + dx}]),
                  finish
                )
              )
            end
          )

        ret |> Map.put({y, x}, val)
      end
    )
  end

  def is_reachable([], _, _, _), do: false
  def is_reachable([finish | _], _, _, finish), do: true

  def is_reachable([{y, x} | rest], map, seen, finish) do
    next =
      [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
      |> Enum.filter(fn {dy, dx} ->
        Map.has_key?(map, {y + dy, x + dx}) and not MapSet.member?(seen, {y + dy, x + dx})
      end)
      |> Enum.map(fn {dy, dx} -> {y + dy, x + dx} end)

    seen = next |> Enum.reduce(seen, fn p, seen -> seen |> MapSet.put(p) end)
    is_reachable(next ++ rest, map, seen, finish)
  end

  def print_path(len, path, map) do
    len |> IO.inspect()

    0..22
    |> Enum.map(fn y ->
      0..22
      |> Enum.map(fn x ->
        if MapSet.member?(path, {y, x}) do
          "O"
        else
          if Map.has_key?(map, {y, x}) do
            Map.get(map, {y, x})
          else
            "#"
          end
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def part2({start, finish, map}) do
    graph = convert_to_graph(map, start, finish)
    # graph |> IO.inspect()
    find_longest([{start, 0, MapSet.new([start])}], finish, graph, 0)
    #  dead_ends = find_dead_ends(map, finish) |> IO.inspect()
    #  find_longest([{start, 0, MapSet.new([start])}], dead_ends, finish, map, 0, true)
  end

  def find_longest([], _, _, max), do: max

  def find_longest([{finish, len, _} | rest], finish, graph, max) when len > max do
    len |> IO.inspect()
    find_longest(rest, finish, graph, len)
  end

  def find_longest([{finish, _, _} | rest], finish, graph, max),
    do: find_longest(rest, finish, graph, max)

  def find_longest([{node, len, seen} | rest], finish, graph, max) do
    next =
      graph
      |> Map.get(node)
      |> Enum.filter(fn {p, _} -> not MapSet.member?(seen, p) end)
      |> Enum.map(fn {next_node, path_len} ->
        {next_node, len + path_len, seen |> MapSet.put(next_node)}
      end)

    find_longest(next ++ rest, finish, graph, max)
  end

  def convert_to_graph(map, start, finish) do
    intersections =
      map
      |> Map.keys()
      |> Enum.filter(fn {y, x} ->
        [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
        |> Enum.filter(fn {dy, dx} ->
          Map.has_key?(map, {y + dy, x + dx})
        end)
        |> Enum.count() > 2
      end)

    int_set = [start, finish | intersections] |> MapSet.new()
    [start, finish | intersections] |> find_neighbors(map, int_set, %{})
  end

  def find_neighbors([], _, _, ret), do: ret

  def find_neighbors([{y, x} = p | rest], map, intersections, ret) do
    n =
      [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
      |> Enum.filter(fn {dy, dx} -> Map.has_key?(map, {y + dy, x + dx}) end)
      |> Enum.map(fn {dy, dx} ->
        walk_until_intersection(
          {y + dy, x + dx},
          MapSet.new([{y, x}, {y + dy, x + dx}]),
          map,
          intersections
        )
      end)

    ret = ret |> Map.put(p, n)
    find_neighbors(rest, map, intersections, ret)
  end

  def walk_until_intersection({y, x} = p, seen, map, intersections) do
    if intersections |> MapSet.member?(p) do
      {p, (seen |> MapSet.size()) - 1}
    else
      [next] =
        [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
        |> Enum.filter(fn {dy, dx} ->
          Map.has_key?(map, {y + dy, x + dx}) and not MapSet.member?(seen, {y + dy, x + dx})
        end)
        |> Enum.map(fn {dy, dx} -> {y + dy, x + dx} end)

      walk_until_intersection(next, seen |> MapSet.put(next), map, intersections)
    end
  end
end
