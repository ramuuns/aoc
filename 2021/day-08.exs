defmodule Day8 do
  def run(mode) do
    start = :erlang.system_time(:microsecond)

    data = read_input(mode)

    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}μs" |> IO.puts()
  end

  def read_input(:test) do
    "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-08")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data),
    do:
      data
      |> Enum.map(fn s ->
        s
        |> String.split(" | ")
        |> Enum.map(&String.split/1)
        |> List.to_tuple()
      end)

  def part1(data) do
    count_fancy_digits(data, 0)
  end

  def part2(data) do
    decode_and_sum_the_values(data, 0)
  end

  def count_fancy_digits([], cnt), do: cnt

  def count_fancy_digits([{_, dig_list} | tail], cnt),
    do: count_fancy_digits(tail, count_fancy_in_list(dig_list, cnt))

  def count_fancy_in_list([], cnt), do: cnt

  def count_fancy_in_list([w | rest], cnt) when byte_size(w) in [2, 3, 4, 7],
    do: count_fancy_in_list(rest, cnt + 1)

  def count_fancy_in_list([_ | rest], cnt), do: count_fancy_in_list(rest, cnt)

  def decode_and_sum_the_values([], sum), do: sum

  def decode_and_sum_the_values([row | rest], sum),
    do: decode_and_sum_the_values(rest, do_one_row(row, sum))

  def do_one_row({use_this_to_figure_out, output}, sum) do
    sum +
      (use_this_to_figure_out
       |> build_decoder()
       |> decode_output(output))
  end

  def build_decoder(input) do
    {non_simple, simple_decoder} = decode_simple(input, {[], %{}})
    reverse_map = simple_decoder |> Enum.reduce(%{}, fn {k, v}, acc -> acc |> Map.put(v, k) end)

    one_chars =
      Map.get(reverse_map, 1)
      |> String.split("")
      |> Enum.filter(fn n -> n != "" end)
      |> MapSet.new()

    {three, non_simple} =
      non_simple
      |> Enum.reduce({nil, []}, fn
        str, {nil, rest} when byte_size(str) == 5 ->
          if one_chars
             |> MapSet.subset?(
               str
               |> String.split("")
               |> Enum.filter(fn n -> n != "" end)
               |> MapSet.new()
             ) do
            {str, rest}
          else
            {nil, [str | rest]}
          end

        str, {three, rest} ->
          {three, [str | rest]}
      end)

    magic_four_chars =
      Map.get(reverse_map, 4)
      |> String.split("")
      |> Enum.filter(fn n -> n != "" end)
      |> MapSet.new()
      |> MapSet.difference(one_chars)

    {five, non_simple} =
      non_simple
      |> Enum.reduce({nil, []}, fn
        str, {nil, rest} when byte_size(str) == 5 ->
          if magic_four_chars
             |> MapSet.subset?(
               str
               |> String.split("")
               |> Enum.filter(fn n -> n != "" end)
               |> MapSet.new()
             ) do
            {str, rest}
          else
            {nil, [str | rest]}
          end

        str, {five, rest} ->
          {five, [str | rest]}
      end)

    {two, non_simple} =
      non_simple
      |> Enum.reduce({nil, []}, fn
        str, {nil, rest} when byte_size(str) == 5 -> {str, rest}
        str, {five, rest} -> {five, [str | rest]}
      end)

    {six, non_simple} =
      non_simple
      |> Enum.reduce({nil, []}, fn
        str, {nil, rest} ->
          if one_chars
             |> MapSet.subset?(
               str
               |> String.split("")
               |> Enum.filter(fn n -> n != "" end)
               |> MapSet.new()
             ) do
            {nil, [str | rest]}
          else
            {str, rest}
          end

        str, {s, rest} ->
          {s, [str | rest]}
      end)

    {nine, zero} =
      non_simple
      |> Enum.reduce({nil, nil}, fn
        str, {n, z} ->
          if magic_four_chars
             |> MapSet.subset?(
               str
               |> String.split("")
               |> Enum.filter(fn n -> n != "" end)
               |> MapSet.new()
             ) do
            {str, z}
          else
            {n, str}
          end
      end)

    simple_decoder
    |> Map.put(three, 3)
    |> Map.put(five, 5)
    |> Map.put(two, 2)
    |> Map.put(six, 6)
    |> Map.put(nine, 9)
    |> Map.put(zero, 0)
    |> sort_keys
  end

  def sort_keys(map) do
    map
    |> Enum.map(fn {k, v} ->
      {k |> String.split("") |> Enum.sort() |> Enum.join(""), v}
    end)
    |> Enum.reduce(%{}, fn {k, v}, m -> m |> Map.put(k, v) end)
  end

  def decode_simple([], dec), do: dec

  def decode_simple([n | rest], {ns, dec}) when byte_size(n) in [2, 3, 4, 7],
    do:
      decode_simple(
        rest,
        {ns,
         dec
         |> Map.put(
           n,
           case byte_size(n) do
             2 -> 1
             3 -> 7
             4 -> 4
             7 -> 8
           end
         )}
      )

  def decode_simple([c | rest], {ns, dec}), do: decode_simple(rest, {[c | ns], dec})

  def decode_output(decoder, output) do
    output
    |> Enum.map(fn o ->
      k = o |> String.split("") |> Enum.sort() |> Enum.join("")
      decoder |> Map.get(k)
    end)
    |> Enum.join("")
    |> String.to_integer()
  end
end

Day8.run(:test)
Day8.run(:actual)
