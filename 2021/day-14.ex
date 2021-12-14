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

  def prepare_data([chain, "" | data]),
    do: prepare_data(data, chain |> String.split("", trim: true) |> make_chain(%{}), %{})

  def prepare_data([], chain, transforms), do: {chain, transforms}

  def prepare_data([transform | rest], chain, transforms),
    do: prepare_data(rest, chain, transforms |> add_transform(transform |> String.split(" -> ")))

  def add_transform(transforms, [from, to]) do
    [a, b] = from |> String.split("", trim: true)
    transforms |> Map.put(from, ["#{a}#{to}", "#{to}#{b}"])
  end

  def make_chain([_ | []], chain), do: chain

  def make_chain([a, b | rest], chain),
    do: make_chain([b | rest], chain |> Map.put("#{a}#{b}", Map.get(chain, "#{a}#{b}", 0) + 1))

  def part1({chain, transforms}) do
    chain |> Map.to_list() |> grow(%{}, transforms, 10) |> min_max_diff
  end

  def part2({chain, transforms}) do
    chain |> Map.to_list() |> grow(%{}, transforms, 40) |> min_max_diff
  end

  def grow([], chain, _, 1), do: chain
  def grow([], chain, transforms, n), do: chain |> Map.to_list() |> grow(%{}, transforms, n - 1)

  def grow([{pair, cnt} | rest], chain, transforms, n) do
    [p1, p2] = transforms |> Map.get(pair)

    grow(
      rest,
      chain
      |> Map.put(p1, Map.get(chain, p1, 0) + cnt)
      |> Map.put(p2, Map.get(chain, p2, 0) + cnt),
      transforms,
      n
    )
  end

  def min_max_diff(chain) do
    {min, max} =
      chain
      |> Enum.reduce({%{}, %{}}, fn
        {pair, cnt}, {aacc, bacc} ->
          [a, b] = pair |> String.split("", trim: true)

          {
            aacc |> Map.put(a, Map.get(aacc, a, 0) + cnt),
            bacc |> Map.put(b, Map.get(bacc, b, 0) + cnt)
          }
      end)
      |> then(fn
        {apos, bpos} ->
          apos
          |> Map.keys()
          |> MapSet.new()
          |> MapSet.union(
            bpos
            |> Map.keys()
            |> MapSet.new()
          )
          |> Enum.reduce(%{}, fn
            key, acc ->
              acc
              |> Map.put(
                key,
                [
                  apos |> Map.get(key, 0),
                  bpos |> Map.get(key, 0)
                ]
                |> Enum.max()
              )
          end)
      end)
      |> Enum.reduce({nil, nil}, fn
        {_, v}, {nil, nil} -> {v, v}
        {_, v}, {min, max} when v < min -> {v, max}
        {_, v}, {min, max} when v > max -> {min, v}
        _, acc -> acc
      end)

    max - min
  end
end
