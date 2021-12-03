defmodule Day3 do
  use Bitwise

  def run(mode) do
    data = read_input(mode)

    start = :erlang.system_time(:microsecond)
    data |> part1() |> IO.puts()
    data |> part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}us" |> IO.puts()
  end

  def read_input(:test) do
    "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-03")
    |> Enum.filter(fn n -> n |> String.trim() != "" end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn s -> s |> String.split("") |> Enum.filter(fn c -> c != "" end) end)
  end

  def part1(data) do
    {freq_list, cnt} = data |> gen_freq_list({[], 0})
    gamma = to_binary(freq_list, cnt, :normal)
    epsilon = to_binary(freq_list, cnt, :not)
    gamma * epsilon
  end

  def count_items([], [], cnt), do: cnt |> Enum.reverse()
  def count_items(["1" | t], [c | t2], cnt), do: count_items(t, t2, [c + 1 | cnt])
  def count_items(["0" | t], [c | t2], cnt), do: count_items(t, t2, [c | cnt])
  def count_items(["1" | t], [], cnt), do: count_items(t, [], [1 | cnt])
  def count_items(["0" | t], [], cnt), do: count_items(t, [], [0 | cnt])

  def to_binary(list, cnt, variety), do: to_binary(list, cnt / 2, variety, 0)
  def to_binary([], _, _, n), do: n

  def to_binary([f | t], cnt, :normal, n),
    do: to_binary(t, cnt, :normal, n <<< 1 ||| if f > cnt do 1 else 0 end )

  def to_binary([f | t], cnt, :not, n),
    do: to_binary(t, cnt, :not, n <<< 1 ||| if f < cnt do 1 else 0 end )

  def string_list_to_binary([], n), do: n
  def string_list_to_binary(["1" | tail], n), do: string_list_to_binary(tail, n <<< 1 ||| 1)
  def string_list_to_binary(["0" | tail], n), do: string_list_to_binary(tail, n <<< 1)

  def gen_freq_list([], freq_list), do: freq_list

  def gen_freq_list([h | t], {freq_list, cnt}),
    do: gen_freq_list(t, {count_items(h, freq_list, []), cnt + 1})

  def part2(data) do
    ox_gen_rating =
      data |> filter_data(0, gen_freq_list(data, {[], 0}), :normal) |> string_list_to_binary(0)

    co_scr_rating =
      data |> filter_data(0, gen_freq_list(data, {[], 0}), :not) |> string_list_to_binary(0)

    ox_gen_rating * co_scr_rating
  end

  def filter_data([item | []], _, _, _), do: item

  def filter_data(data, at, {freq_list, cnt}, mode) do
    h_cnt = cnt / 2

    filtered =
      data
      |> Enum.filter(fn num ->
        n = num |> Enum.at(at)
        f = freq_list |> Enum.at(at)

        if mode == :normal do
          (n == "1" and f >= h_cnt) or (n == "0" and f < h_cnt)
        else
          (n == "0" and f >= h_cnt) or (n == "1" and f < h_cnt)
        end
      end)

    filter_data(filtered, at + 1, gen_freq_list(filtered, {[], 0}), mode)
  end
end

Day3.run(:test)
Day3.run(:actual)
