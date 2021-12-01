defmodule Day1 do
  def run(mode) do
    data = read_input(mode)

    start = :erlang.system_time(:microsecond)
    data |> fancy_part1() |> IO.puts()
    data |> fancy_part2() |> IO.puts()
    finish = :erlang.system_time(:microsecond)
    "took #{finish - start}ms" |> IO.puts()
  end

  def read_input(:test) do
    "199
200
208
210
200
207
240
269
260
    263"
    |> String.split("\n")
    |> Enum.map(fn i ->
      i
      |> String.trim()
      |> String.to_integer()
    end)
  end

  def read_input(:actual) do
    File.stream!("input-01")
    |> Enum.filter(fn n -> n |> String.trim() != "" end)
    |> Enum.map(fn n -> n |> String.trim() |> String.to_integer() end)
  end

  def fancy_part1([h | tail]), do: fancy_part1(tail, {h, 0})
  def fancy_part1([], {_, cnt}), do: cnt
  def fancy_part1([h | tail], {p, cnt}) when h > p, do: fancy_part1(tail, {h, cnt + 1})
  def fancy_part1([h | tail], {_, cnt}), do: fancy_part1(tail, {h, cnt})

  def fancy_part2([one, two, three | tail]), do: fancy_part2(tail, {one, two, three, 0})
  def fancy_part2([], {_, _, _, cnt}), do: cnt

  def fancy_part2([h | tail], {p1, p2, p3, cnt}) when h > p1,
    do: fancy_part2(tail, {p2, p3, h, cnt + 1})

  def fancy_part2([h | tail], {_, p2, p3, cnt}), do: fancy_part2(tail, {p2, p3, h, cnt})
end

Day1.run(:test)
Day1.run(:actual)
