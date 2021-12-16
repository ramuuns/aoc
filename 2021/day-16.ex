defmodule Day16 do
  use Bitwise

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "C200B40A82"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-16")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([input]) do
    len = byte_size(input)
    num = input |> String.to_integer(16)
    <<num::integer-size(len)-unit(4)>>
  end

  def part1(data) do
    recurse_decode_packets(data, :version_num, 0)
  end

  def part2(data) do
    recurse_decode_packets(data, :eval, []) |> Enum.at(0)
  end

  def recurse_decode_packets(<<version::3, 4::3, rest::bits>>, :version_num, acc) do
    {rest, _} = read_value(rest, 0)
    recurse_decode_packets(rest, :version_num, acc + version)
  end

  def recurse_decode_packets(
        <<version::3, _::3, 1::1, _::11, rest::bits>>,
        :version_num,
        acc
      ),
      do: recurse_decode_packets(rest, :version_num, acc + version)

  def recurse_decode_packets(
        <<version::3, _::3, 0::1, _::15, rest::bits>>,
        :version_num,
        acc
      ),
      do: recurse_decode_packets(rest, :version_num, acc + version)

  def recurse_decode_packets(<<_::3, 4::3, rest::bits>>, :eval, acc) do
    {rest, val} = read_value(rest, 0)
    recurse_decode_packets(rest, :eval, [val | acc])
  end

  def recurse_decode_packets(
        <<_::3, type::3, 0::1, sub_len::15, rest::bits>>,
        :eval,
        acc
      ) do
    <<sub_rest::bits-size(sub_len), rest::bits>> = rest
    values = recurse_decode_packets(sub_rest, :eval, [])
    value = calc_value(values, type)
    recurse_decode_packets(rest, :eval, [value | acc])
  end

  def recurse_decode_packets(
        <<_::3, type::3, 1::1, num_subpackets::11, rest::bits>>,
        :eval,
        acc
      ) do
    {values, rest} = decode_n_subpackets(rest, [], num_subpackets)
    value = calc_value(values, type)
    recurse_decode_packets(rest, :eval, [value | acc])
  end

  def recurse_decode_packets(_, _, acc), do: acc

  def decode_n_subpackets(rest, acc, 0), do: {acc, rest}

  def decode_n_subpackets(<<_::3, 4::3, rest::bits>>, acc, n) do
    {rest, val} = read_value(rest, 0)
    decode_n_subpackets(rest, [val | acc], n - 1)
  end

  def decode_n_subpackets(
        <<_::3, type::3, 0::1, sub_len::15, rest::bits>>,
        acc,
        n
      ) do
    <<sub_rest::bits-size(sub_len), rest::bits>> = rest
    values = recurse_decode_packets(sub_rest, :eval, [])
    value = calc_value(values, type)
    decode_n_subpackets(rest, [value | acc], n - 1)
  end

  def decode_n_subpackets(
        <<_::3, type::3, 1::1, num_subpackets::11, rest::bits>>,
        acc,
        n
      ) do
    {values, rest} = decode_n_subpackets(rest, [], num_subpackets)
    value = calc_value(values, type)
    decode_n_subpackets(rest, [value | acc], n - 1)
  end

  def read_value(<<1::1, n::4, rest::bits>>, val),
    do: read_value(rest, (val <<< 4) + n)

  def read_value(<<0::1, n::4, rest::bits>>, val),
    do: {rest, (val <<< 4) + n}

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
