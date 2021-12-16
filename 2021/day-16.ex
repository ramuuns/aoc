defmodule Day16 do
  Code.compile_file("priority_queue.ex")

  use Bitwise

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "F600BC2D8F"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-16")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([data]) do
    data
    |> String.split("", trim: true)
    |> Enum.flat_map(fn
      "0" -> [0, 0, 0, 0]
      "1" -> [0, 0, 0, 1]
      "2" -> [0, 0, 1, 0]
      "3" -> [0, 0, 1, 1]
      "4" -> [0, 1, 0, 0]
      "5" -> [0, 1, 0, 1]
      "6" -> [0, 1, 1, 0]
      "7" -> [0, 1, 1, 1]
      "8" -> [1, 0, 0, 0]
      "9" -> [1, 0, 0, 1]
      "A" -> [1, 0, 1, 0]
      "B" -> [1, 0, 1, 1]
      "C" -> [1, 1, 0, 0]
      "D" -> [1, 1, 0, 1]
      "E" -> [1, 1, 1, 0]
      "F" -> [1, 1, 1, 1]
    end)
  end

  def part1(data) do
    recurse_decode_packets(data, :version_num, 0)
  end

  def part2(data) do
    recurse_decode_packets(data, :eval, []) |> Enum.at(0)
  end

  def recurse_decode_packets([v1, v2, v3, 1, 0, 0 | rest], :version_num, acc) do
    acc = bits_to_num([v1, v2, v3], 0) + acc
    {rest, _} = read_value(rest, 0)
    recurse_decode_packets(rest, :version_num, acc)
  end

  def recurse_decode_packets(
        [v1, v2, v3, _, _, _, 1, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11 | rest],
        :version_num,
        acc
      ) do
    acc = bits_to_num([v1, v2, v3], 0) + acc
    _num_subpackets = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11], 0)
    recurse_decode_packets(rest, :version_num, acc)
  end

  def recurse_decode_packets(
        [
          v1,
          v2,
          v3,
          _,
          _,
          _,
          0,
          n1,
          n2,
          n3,
          n4,
          n5,
          n6,
          n7,
          n8,
          n9,
          n10,
          n11,
          n12,
          n13,
          n14,
          n15 | rest
        ],
        :version_num,
        acc
      ) do
    acc = bits_to_num([v1, v2, v3], 0) + acc
    _sub_len = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15], 0)
    recurse_decode_packets(rest, :version_num, acc)
  end

  def recurse_decode_packets([_, _, _, 1, 0, 0 | rest], :eval, acc) do
    {rest, val} = read_value(rest, 0)
    recurse_decode_packets(rest, :eval, [val | acc])
  end

  def recurse_decode_packets(
        [
          _,
          _,
          _,
          t1,
          t2,
          t3,
          0,
          n1,
          n2,
          n3,
          n4,
          n5,
          n6,
          n7,
          n8,
          n9,
          n10,
          n11,
          n12,
          n13,
          n14,
          n15 | rest
        ],
        :eval,
        acc
      ) do
    sub_len = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15], 0)
    type = bits_to_num([t1, t2, t3], 0)
    {sub_rest, rest} = rest |> Enum.split(sub_len)
    values = recurse_decode_packets(sub_rest, :eval, [])
    value = calc_value(values, type)
    recurse_decode_packets(rest, :eval, [value | acc])
  end

  def recurse_decode_packets(
        [_, _, _, t1, t2, t3, 1, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11 | rest],
        :eval,
        acc
      ) do
    num_subpackets = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11], 0)
    type = bits_to_num([t1, t2, t3], 0)
    {values, rest} = decode_n_subpackets(rest, [], num_subpackets)
    value = calc_value(values, type)
    recurse_decode_packets(rest, :eval, [value | acc])
  end

  def recurse_decode_packets(_, _, acc), do: acc

  def decode_n_subpackets(rest, acc, 0), do: {acc, rest}

  def decode_n_subpackets([_, _, _, 1, 0, 0 | rest], acc, n) do
    {rest, val} = read_value(rest, 0)
    decode_n_subpackets(rest, [val | acc], n - 1)
  end

  def decode_n_subpackets(
        [
          _,
          _,
          _,
          t1,
          t2,
          t3,
          0,
          n1,
          n2,
          n3,
          n4,
          n5,
          n6,
          n7,
          n8,
          n9,
          n10,
          n11,
          n12,
          n13,
          n14,
          n15 | rest
        ],
        acc,
        n
      ) do
    sub_len = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15], 0)
    type = bits_to_num([t1, t2, t3], 0)
    {sub_rest, rest} = rest |> Enum.split(sub_len)
    values = recurse_decode_packets(sub_rest, :eval, [])
    value = calc_value(values, type)
    decode_n_subpackets(rest, [value | acc], n - 1)
  end

  def decode_n_subpackets(
        [_, _, _, t1, t2, t3, 1, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11 | rest],
        acc,
        n
      ) do
    num_subpackets = bits_to_num([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11], 0)
    type = bits_to_num([t1, t2, t3], 0)
    {values, rest} = decode_n_subpackets(rest, [], num_subpackets)
    value = calc_value(values, type)
    decode_n_subpackets(rest, [value | acc], n - 1)
  end

  def bits_to_num([], acc), do: acc
  def bits_to_num([1 | rest], acc), do: bits_to_num(rest, (acc <<< 1) + 1)
  def bits_to_num([0 | rest], acc), do: bits_to_num(rest, acc <<< 1)

  def read_value([1, a, b, c, d | rest], val),
    do: read_value(rest, (val <<< 4) + bits_to_num([a, b, c, d], 0))

  def read_value([0, a, b, c, d | rest], val),
    do: {rest, (val <<< 4) + bits_to_num([a, b, c, d], 0)}

  def calc_value(values, 0), do: Enum.sum(values)
  def calc_value(values, 1), do: Enum.reduce(values, 1, fn n, p -> p * n end)
  def calc_value(values, 2), do: Enum.min(values)
  def calc_value(values, 3), do: Enum.max(values)
  # the 5 and the 6 need to be done in reversed order because our lists are reversed
  def calc_value([a, b], 5) when a < b, do: 1
  def calc_value(_, 5), do: 0
  def calc_value([a, b], 6) when a > b, do: 1
  def calc_value(_, 6), do: 0
  def calc_value([a, a], 7), do: 1
  def calc_value(_, 7), do: 0
end
