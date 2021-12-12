defmodule Day12 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "start-A
start-b
A-c
A-b
b-d
A-end
b-end"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-12")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, %{})
  def prepare_data([], acc), do: acc

  def prepare_data([path | rest], acc),
    do:
      prepare_data(
        rest,
        acc |> add_path(path |> String.split("-", trim: true) |> List.to_tuple())
      )

  def add_path(graph, {from, to}) do
    {from, from_small} = {String.to_atom(from), from |> String.downcase() == from}
    {to, to_small} = {String.to_atom(to), to |> String.downcase() == to}

    graph
    |> Map.put(from, [{to, to_small} | graph |> Map.get(from, [])])
    |> Map.put(to, [{from, from_small} | graph |> Map.get(to, [])])
  end

  def part1(data) do
    data |> find_all_paths([{{:start, true}, %{}}], 0)
  end

  def find_all_paths(_, [], paths), do: paths

  def find_all_paths(graph, [{{:end, true}, _} | to_visit], paths),
    do: find_all_paths(graph, to_visit, 1 + paths)

  def find_all_paths(graph, [{{node, true}, seen} | to_visit], paths) when is_map_key(seen, node),
    do: find_all_paths(graph, to_visit, paths)

  def find_all_paths(graph, [{{node, true}, seen} | to_visit], paths),
    do: find_all_paths(graph, graph[node] |> add_paths(seen |> Map.put(node, 1), to_visit), paths)

  def find_all_paths(graph, [{{node, false}, seen} | to_visit], paths),
    do: find_all_paths(graph, graph[node] |> add_paths(seen, to_visit), paths)

  def add_paths([], _, to_visit), do: to_visit

  def add_paths([node | rest], seen, to_visit),
    do: add_paths(rest, seen, [{node, seen} | to_visit])

  def part2(data) do
    data |> find_all_pathsp2([{{:start, true}, %{}, nil}], 0)
  end

  def find_all_pathsp2(_, [], paths), do: paths

  def find_all_pathsp2(graph, [{{:end, _}, _, _} | to_visit], paths),
    do: find_all_pathsp2(graph, to_visit, 1 + paths)

  def find_all_pathsp2(graph, [{{node, _}, _, node} | to_visit], paths),
    do: find_all_pathsp2(graph, to_visit, paths)

  def find_all_pathsp2(graph, [{{node, true}, seen, seen2} | to_visit], paths)
      when seen2 != nil and is_map_key(seen, node),
      do: find_all_pathsp2(graph, to_visit, paths)

  def find_all_pathsp2(graph, [{{:start, true}, seen, _} | to_visit], paths)
      when is_map_key(seen, :start),
      do: find_all_pathsp2(graph, to_visit, paths)

  def find_all_pathsp2(graph, [{{node, false}, seen1, seen2} | to_visit], paths),
    do: find_all_pathsp2(graph, graph[node] |> add_pathsp2(seen1, seen2, to_visit), paths)

  def find_all_pathsp2(graph, [{{node, true}, seen1, nil} | to_visit], paths)
      when is_map_key(seen1, node),
      do: find_all_pathsp2(graph, graph[node] |> add_pathsp2(seen1, node, to_visit), paths)

  def find_all_pathsp2(graph, [{{node, true}, seen1, seen2} | to_visit], paths)
      when is_map_key(seen1, node),
      do: find_all_pathsp2(graph, graph[node] |> add_pathsp2(seen1, seen2, to_visit), paths)

  def find_all_pathsp2(graph, [{{node, true}, seen1, seen2} | to_visit], paths),
    do:
      find_all_pathsp2(
        graph,
        graph[node] |> add_pathsp2(seen1 |> Map.put(node, 1), seen2, to_visit),
        paths
      )

  def add_pathsp2([], _, _, to_visit), do: to_visit

  def add_pathsp2([node | rest], seen1, seen2, to_visit),
    do: add_pathsp2(rest, seen1, seen2, [{node, seen1, seen2} | to_visit])
end
