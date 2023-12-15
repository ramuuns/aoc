defmodule Day15 do
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
    "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-15")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([data]) do
    data |> String.split(",", trim: true)
  end

  def part1(data) do
    data
    |> Enum.reduce(0, fn i, sum -> sum + hash(i, 0) end)
  end

  def hash("", val), do: val
  def hash(<<c::utf8, rest::binary>>, val), do: hash(rest, rem((val + c) * 17, 256))

  def part2(data) do
    put_lenses_in_boxes(data, %{})
  end

  def put_lenses_in_boxes([], lenses), do: focal_power(Map.keys(lenses), lenses, 0)

  def put_lenses_in_boxes([instr | rest], lenses) do
    {hash_label, label, instr} = parse_instr(instr, 0, [])
    list = Map.get(lenses, hash_label, [])

    list =
      case instr do
        :del -> list |> Enum.filter(fn {lab, _} -> lab != label end)
        _ -> list |> insert_or_update(label, instr, false, [])
      end

    put_lenses_in_boxes(rest, lenses |> Map.put(hash_label, list))
  end

  def parse_instr("-", hash, label), do: {hash, label |> Enum.reverse() |> to_string, :del}

  def parse_instr("=" <> val, hash, label),
    do: {hash, label |> Enum.reverse() |> to_string, val |> String.to_integer()}

  def parse_instr(<<c::utf8, rest::binary>>, hash, label),
    do: parse_instr(rest, rem((hash + c) * 17, 256), [c | label])

  def insert_or_update([], label, value, true, list), do: list |> Enum.reverse()

  def insert_or_update([], label, value, false, list),
    do: [{label, value} | list] |> Enum.reverse()

  def insert_or_update([h | rest], label, value, true, list),
    do: insert_or_update(rest, label, value, true, [h | list])

  def insert_or_update([{label, _} | rest], label, value, false, list),
    do: insert_or_update(rest, label, value, true, [{label, value} | list])

  def insert_or_update([h | rest], label, value, false, list),
    do: insert_or_update(rest, label, value, false, [h | list])

  def focal_power([], _, fp), do: fp

  def focal_power([k | rest], map, fp),
    do: focal_power(rest, map, fp + focal_powers(Map.get(map, k), k + 1, 1, 0))

  def focal_powers([], _, _, fp), do: fp

  def focal_powers([{_, val} | rest], k, i, fp),
    do: focal_powers(rest, k, i + 1, fp + val * k * i)
end
