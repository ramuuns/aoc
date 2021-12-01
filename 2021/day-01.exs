defmodule Day1 do
  def run(mode) do
    data = read_input(mode)

    data |> part_1() |> IO.inspect()

    data |> part_2() |> IO.inspect()
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

  def part_1([first | data]) do
    {_, cnt} =
      data
      |> Enum.reduce({first, 0}, fn n, {p, cnt} ->
        if n > p do
          {n, cnt + 1}
        else
          {n, cnt}
        end
      end)

    cnt
  end

  def part_2([first, second, third | data]) do
    {_, _, _, cnt} =
      data
      |> Enum.reduce({first, second, third, 0}, fn n, {p1, p2, p3, cnt} ->
        if n > p1 do
          {p2, p3, n, cnt + 1}
        else
          {p2, p3, n, cnt}
        end
      end)

    cnt
  end
end

Day1.run(:test)
Day1.run(:actual)
