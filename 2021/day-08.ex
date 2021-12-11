defmodule Day8 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
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
    data
    |> Task.async_stream(&do_one_row/1)
    |> Enum.reduce(0, fn {:ok, rowsum}, sum -> sum + rowsum end)
  end

  def count_fancy_digits([], cnt), do: cnt

  def count_fancy_digits([{_, dig_list} | tail], cnt),
    do: count_fancy_digits(tail, count_fancy_in_list(dig_list, cnt))

  def count_fancy_in_list([], cnt), do: cnt

  def count_fancy_in_list([w | rest], cnt) when byte_size(w) in [2, 3, 4, 7],
    do: count_fancy_in_list(rest, cnt + 1)

  def count_fancy_in_list([_ | rest], cnt), do: count_fancy_in_list(rest, cnt)

  def do_one_row({input, output}) do
    input
    |> build_decoder()
    |> decode_output(output)
  end

  def string_to_set(string), do: string |> String.split("", trim: true) |> MapSet.new()

  def build_decoder(input) do
    {non_simple, simple_decoder} = decode_simple(input, {[], %{}})

    {one_chars, four_chars} =
      simple_decoder
      |> Enum.reduce({nil, nil}, fn
        {k, v}, {_, four} when v == 1 -> {k, four}
        {k, v}, {one, _} when v == 4 -> {one, k}
        _, acc -> acc
      end)

    one_chars = one_chars |> string_to_set
    magic_four_chars = four_chars |> string_to_set |> MapSet.difference(one_chars)

    {len_six, len_five} =
      non_simple
      |> Enum.reduce({[], []}, fn
        str, {len_six, len_five} when byte_size(str) == 5 -> {len_six, [str | len_five]}
        str, {len_six, len_five} -> {[str | len_six], len_five}
      end)

    {two, three, five} =
      len_five
      |> Enum.reduce({nil, nil, nil}, fn
        str, {two, three, five} ->
          cond do
            one_chars |> MapSet.subset?(str |> string_to_set) -> {two, str, five}
            magic_four_chars |> MapSet.subset?(str |> string_to_set) -> {two, three, str}
            true -> {str, three, five}
          end
      end)

    {six, nine, zero} =
      len_six
      |> Enum.reduce({nil, nil, nil}, fn str, {six, nine, zero} ->
        cond do
          four_chars |> string_to_set() |> MapSet.subset?(str |> string_to_set) ->
            {six, str, zero}

          one_chars |> MapSet.subset?(str |> string_to_set) ->
            {six, nine, str}

          true ->
            {str, nine, zero}
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

