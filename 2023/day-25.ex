defmodule Day25 do
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
    "jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-25")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data |> into_graph(%{})
  end

  def merge_edges([], edges), do: edges

  def merge_edges([{e, s} | rest], edges),
    do: merge_edges(rest, edges |> Map.put(e, Map.get(edges, e, 0) + s))

  def merge_edges([e | rest], edges),
    do: merge_edges(rest, edges |> Map.put(e, Map.get(edges, e, 0) + 1))

  def into_graph([], graph), do: graph

  def into_graph([node | rest], graph) do
    [name | connects_to] = String.split(node, ~r":? ", trim: true) |> Enum.map(&String.to_atom/1)
    node = Map.get(graph, name, %{nodes: MapSet.new([name]), edges: %{}})
    node = %{node | edges: connects_to |> merge_edges(node.edges)}

    graph =
      connects_to
      |> Enum.reduce(
        graph,
        fn c, graph ->
          other = Map.get(graph, c, %{nodes: MapSet.new([c]), edges: %{}})
          graph |> Map.put(c, %{other | edges: [name] |> merge_edges(other.edges)})
        end
      )

    graph = graph |> Map.put(name, node)
    into_graph(rest, graph)
  end

  def part1(data) do
    res = run_until_mincut_is_three(data)
    res
  end

  def run_until_mincut_is_three(graph) do
    g = contract_while(graph)
    [k1, k2] = Map.keys(g)

    if g[k1].edges[k2] == 3 do
      s1 = g[k1].nodes |> MapSet.size()
      s2 = g[k2].nodes |> MapSet.size()
      s1 * s2
    else
      run_until_mincut_is_three(graph)
    end
  end

  def contract_while(graph) do
    case Map.keys(graph) do
      [_, _] -> graph
      _ -> graph |> contract() |> contract_while()
    end
  end

  def contract(graph) do
    [random_node | _] = graph |> Map.keys() |> Enum.shuffle()
    %{edges: other_nodes} = this_node = graph |> Map.get(random_node)
    [other_random_node | _] = other_nodes |> Map.keys() |> Enum.shuffle()
    other_node = graph |> Map.get(other_random_node)

    this_node = %{
      this_node
      | nodes: this_node.nodes |> MapSet.union(other_node.nodes),
        edges:
          other_node.edges
          |> Map.delete(random_node)
          |> Map.to_list()
          |> merge_edges(this_node.edges |> Map.delete(other_random_node))
    }

    graph =
      other_node.edges
      |> Map.delete(random_node)
      |> Enum.reduce(graph, fn {key, c}, graph ->
        n = graph |> Map.get(key)

        n = %{
          n
          | edges: merge_edges([{random_node, c}], n.edges |> Map.delete(other_random_node))
        }

        graph |> Map.put(key, n)
      end)
      |> Map.delete(other_random_node)
      |> Map.put(random_node, this_node)

    graph
  end

  def part2(data) do
    2
  end
end
