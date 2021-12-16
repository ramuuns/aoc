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
    recurse_decode_packets(data, :version_num, 0, nil)
  end

  def part2(data) do
    recurse_decode_packets(data, :eval, [], [{-1, -1, nil, nil}]) |> Enum.at(0)
  end

  def recurse_decode_packets(<<version::3, 4::3, rest::bits>>, :version_num, acc, nil) do
    {rest, _, _} = read_value(rest, 0, 0)
    recurse_decode_packets(rest, :version_num, acc + version, nil)
  end

  def recurse_decode_packets(
        <<version::3, _::3, 1::1, _::11, rest::bits>>,
        :version_num,
        acc,
        nil
      ),
      do: recurse_decode_packets(rest, :version_num, acc + version, nil)

  def recurse_decode_packets(
        <<version::3, _::3, 0::1, _::15, rest::bits>>,
        :version_num,
        acc,
        nil
      ),
      do: recurse_decode_packets(rest, :version_num, acc + version, nil)

  # pop the stack on "n packets have been read"
  # note that we have to also ensure that we "add" the number of bits we've read while doing so to the next level of the stack
  def recurse_decode_packets(bits, :eval, acc, [
        {0, bits_read, op, stacked_acc},
        {n, b, op2, s2} | opstack
      ]),
      do:
        recurse_decode_packets(bits, :eval, [acc |> calc_value(op) | stacked_acc], [
          {n, b + (1 + bits_read), op2, s2} | opstack
        ])

  # pop the stack on "we've read n bits"
  def recurse_decode_packets(bits, :eval, acc, [{_, 0, op, stacked_acc} | opstack]),
    do: recurse_decode_packets(bits, :eval, [acc |> calc_value(op) | stacked_acc], opstack)

  #  read the value packets
  def recurse_decode_packets(<<_::3, 4::3, rest::bits>>, :eval, acc, [{n, b, op, stacc} | opstack]) do
    {rest, val, bits_read} = read_value(rest, 0, 0)

    recurse_decode_packets(rest, :eval, [val | acc], [
      {n - 1, b - bits_read - 6, op, stacc} | opstack
    ])
  end

  # read the subpacket has sub_len bits op packet
  def recurse_decode_packets(
        <<_::3, type::3, 0::1, sub_len::15, rest::bits>>,
        :eval,
        acc,
        [{n, b, op, stacc} | opstack]
      ) do
    recurse_decode_packets(rest, :eval, [], [
      {-1, sub_len, type, acc},
      {n - 1, b - sub_len - 22, op, stacc} | opstack
    ])
  end

  # read the subpacket has num_subpackets operands op packet
  def recurse_decode_packets(
        <<_::3, type::3, 1::1, num_subpackets::11, rest::bits>>,
        :eval,
        acc,
        [{n, b, op, stacc} | opstack]
      ) do
    recurse_decode_packets(rest, :eval, [], [
      {num_subpackets, -1, type, acc},
      {n - 1, b - 18, op, stacc} | opstack
    ])
  end

  def recurse_decode_packets(_, _, acc, _), do: acc

  def read_value(<<1::1, n::4, rest::bits>>, val, bits),
    do: read_value(rest, (val <<< 4) + n, bits + 5)

  def read_value(<<0::1, n::4, rest::bits>>, val, bits),
    do: {rest, (val <<< 4) + n, bits + 5}

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
