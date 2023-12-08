defmodule Day8 do
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
    "LR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-08")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    [instr, "" | nodes] = data

    {instr |> String.split("", trim: true),
     nodes
     |> Enum.reduce(
       %{},
       fn node, nodes ->
         [key, values] = node |> String.split(" = ", trim: true)

         [left, right] =
           values |> String.replace(~r"\)|\(", "") |> String.split(", ", trim: true)

         nodes
         |> Map.put(
           key |> String.reverse(),
           {left |> String.reverse(), right |> String.reverse()}
         )
       end
     )}
  end

  def part1({steps, nodes}) do
    count_steps(steps, steps, nodes, "AAA", 0)
  end

  def count_steps(_, _, _, "ZZZ", ret), do: ret
  def count_steps([], steps, nodes, node, ret), do: count_steps(steps, steps, nodes, node, ret)

  def count_steps(["L" | rest], steps, nodes, node, ret) do
    {next, _} = Map.get(nodes, node)
    count_steps(rest, steps, nodes, next, ret + 1)
  end

  def count_steps(["R" | rest], steps, nodes, node, ret) do
    {_, next} = Map.get(nodes, node)
    count_steps(rest, steps, nodes, next, ret + 1)
  end

  def part2({steps, nodes}) do
    start_nodes =
      nodes
      |> Map.keys()
      |> Enum.filter(fn
        "A" <> _ -> true
        _ -> false
      end)

    start_nodes
    |> Enum.map(fn node -> count_steps_2(steps, steps, nodes, node, 0) end)
    |> Enum.reduce(1, fn n, r -> div(r * n, Integer.gcd(r, n)) end)
  end

  def count_steps_2(_, _, _, "Z" <> _, ret), do: ret

  def count_steps_2([], steps, nodes, node, ret),
    do: count_steps_2(steps, steps, nodes, node, ret)

  def count_steps_2(["L" | rest], steps, nodes, node, ret) do
    {next, _} = Map.get(nodes, node)
    count_steps_2(rest, steps, nodes, next, ret + 1)
  end

  def count_steps_2(["R" | rest], steps, nodes, node, ret) do
    {_, next} = Map.get(nodes, node)
    count_steps_2(rest, steps, nodes, next, ret + 1)
  end
end
