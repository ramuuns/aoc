defmodule Day14 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-14")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([chain, "" | data]), do: prepare_data(data, chain |> String.split("", trim: true), %{})
  def prepare_data([], chain, transforms), do: {chain, transforms}
  def prepare_data([transform | rest ], chain, transforms), do: prepare_data(rest, chain, transforms |> add_transform(transform |> String.split(" -> ")))

  def add_transform(transforms, [from, to]), do: transforms |> Map.put( from |> String.split("", trim: true) |> List.to_tuple, to)


  def part1({chain, transforms}) do
    chain |> grow([], transforms, 10, :normal) |> min_max_diff
  end

  def part2({chain, transforms}) do
    {min, max} = chain 
    |> grow([], transforms, 20, :normal)
    |> count_pair_growth(transforms, %{}, %{})
    |> Enum.reduce({nil, nil}, fn                
      {_, v}, {nil, nil} -> {v, v}
      {_, v}, {min, max} when v < min -> {v, max}
      {_, v}, {min, max} when v > max -> {min, v}
      _, acc -> acc
    end)
    max - min
  end

  def grow(chain, _, _, 0, _), do: chain
  def grow([a | []], chain, transforms, n, :normal) do 
    grow([ a | chain], [], transforms, n - 1, :reversed)
  end

  def grow([a | []], chain, transforms, n, :reversed) do
    grow([a | chain], [], transforms, n - 1, :normal)
  end
  def grow([a, b | chain], newchain, transforms, n, :normal) when not is_map_key(transforms, {a,b}), 
    do: grow([b | chain], [ a | newchain ], transforms, n, :normal)
  def grow([a, b | chain], newchain, transforms, n, :reversed) when not is_map_key(transforms, {b,a}), 
    do: grow([b | chain], [ a | newchain ], transforms, n, :reversed)
  def grow([a, b | chain], newchain, transforms, n, :normal), do: grow([b | chain], [transforms |> Map.get({a,b}), a | newchain], transforms, n, :normal)
  def grow([a, b | chain], newchain, transforms, n, :reversed), do: grow([b | chain], [transforms |> Map.get({b,a}), a | newchain], transforms, n, :reversed)

  def min_max_diff(chain) do
    {min, max} = chain |> Enum.frequencies() |> Enum.reduce({nil, nil}, fn 
      {_, v}, {nil, nil} -> {v, v}
      {_, v}, {min, max} when v < min -> {v, max}
      {_, v}, {min, max} when v > max -> {min, v}
      _, acc -> acc
    end) 
    max - min
  end

  def count_pair_growth([b | []], _, _, chars), do: chars |> Map.put(b, Map.get(chars, b) + 1)
  def count_pair_growth([a,b | rest], transforms, pair_counts, chars) when is_map_key(pair_counts, {a,b}) do
    count_pair_growth([b | rest], transforms, pair_counts, chars |> add_count(pair_counts |> Map.get({a,b}), a,b))
  end

  def count_pair_growth([a, b | rest], transforms, pair_counts, chars) do
    pair_counts_this_pair = [a,b] |> grow([], transforms, 20, :normal) |> Enum.frequencies() |> Map.map(fn
      {^a, v} -> v - 1
      {^b, v} -> v - 1
      {_, v} -> v 
    end)
    count_pair_growth([b | rest], transforms, pair_counts |> Map.put({a,b}, pair_counts_this_pair), chars |> add_count(pair_counts_this_pair, a,b))
  end


  def add_count(to, what, a, b) do
    chars = what |> Enum.reduce(to, fn {k, v}, acc -> acc |> Map.put(k, Map.get(acc, k, 0) + v) end)
    chars 
    |> Map.put(a, Map.get(chars, a) + 1)
    # this is in case a == b we need to _not_ add anything to it, so if that's the case then we simply overwrite it with the count as was
    |> Map.put(b, Map.get(chars, b) + 0)
  end
end
