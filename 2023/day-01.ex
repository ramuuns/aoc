defmodule Day1 do
  def run(mode) do
    data = read_input(mode)

    p2_data = read_input_2(mode)

    [{1, data}, {2, p2_data}]
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
    "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-01")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def read_input_2(:test) do
    "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input_2(:actual), do: read_input(:actual)

  def prepare_data(data) do
    data
  end

  def part1(data) do
    data |> create_nums_and_sum(0)
  end

  def part2(data) do
    data |> create_nums_and_sum_p2(0)
  end

  def create_nums_and_sum([], sum), do: sum
  def create_nums_and_sum([str | rest], sum), do: create_nums_and_sum(rest, sum + create_num(str))

  def create_num(str), do: create_num_inner(str |> String.split("", trim: true), -1, -1)

  def create_num_inner([], a, b), do: a * 10 + b

  def create_num_inner([ch | rest], -1, -1) when ch >= "0" and ch <= "9",
    do: create_num_inner(rest, String.to_integer(ch), String.to_integer(ch))

  def create_num_inner([ch | rest], num, _) when ch >= "0" and ch <= "9" and num >= 0,
    do: create_num_inner(rest, num, String.to_integer(ch))

  def create_num_inner([_ | rest], a, b) do
    create_num_inner(rest, a, b)
  end

  def create_nums_and_sum_p2([], sum), do: sum

  def create_nums_and_sum_p2([str | rest], sum),
    do: create_nums_and_sum_p2(rest, sum + create_num_p2(str))

  def create_num_p2(str), do: create_num_p2_inner(str, -1, -1)

  def create_num_p2_inner("", a, b), do: a * 10 + b
  def create_num_p2_inner("one" <> rest, -1, _), do: create_num_p2_inner("e" <> rest, 1, 1)
  def create_num_p2_inner("two" <> rest, -1, _), do: create_num_p2_inner("o" <> rest, 2, 2)
  def create_num_p2_inner("three" <> rest, -1, _), do: create_num_p2_inner("e" <> rest, 3, 3)
  def create_num_p2_inner("four" <> rest, -1, _), do: create_num_p2_inner(rest, 4, 4)
  def create_num_p2_inner("five" <> rest, -1, _), do: create_num_p2_inner("e" <> rest, 5, 5)
  def create_num_p2_inner("six" <> rest, -1, _), do: create_num_p2_inner(rest, 6, 6)
  def create_num_p2_inner("seven" <> rest, -1, _), do: create_num_p2_inner("n" <> rest, 7, 7)
  def create_num_p2_inner("eight" <> rest, -1, _), do: create_num_p2_inner("t" <> rest, 8, 8)
  def create_num_p2_inner("nine" <> rest, -1, _), do: create_num_p2_inner("e" <> rest, 9, 9)

  def create_num_p2_inner(<<ch::utf8, rest::binary>>, -1, _) when ch >= 48 and ch <= 57,
    do: create_num_p2_inner(rest, ch - 48, ch - 48)

  def create_num_p2_inner("one" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("e" <> rest, num, 1)

  def create_num_p2_inner("two" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("o" <> rest, num, 2)

  def create_num_p2_inner("three" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("e" <> rest, num, 3)

  def create_num_p2_inner("four" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner(rest, num, 4)

  def create_num_p2_inner("five" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("e" <> rest, num, 5)

  def create_num_p2_inner("six" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner(rest, num, 6)

  def create_num_p2_inner("seven" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("n" <> rest, num, 7)

  def create_num_p2_inner("eight" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("t" <> rest, num, 8)

  def create_num_p2_inner("nine" <> rest, num, _) when num >= 0,
    do: create_num_p2_inner("e" <> rest, num, 9)

  def create_num_p2_inner(<<ch::utf8, rest::binary>>, num, _)
      when ch >= 48 and ch <= 57 and num >= 0,
      do: create_num_p2_inner(rest, num, ch - 48)

  def create_num_p2_inner(<<_::utf8, rest::binary>>, a, b), do: create_num_p2_inner(rest, a, b)
end
