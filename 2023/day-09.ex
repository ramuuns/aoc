defmodule Day9 do
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
    "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-09")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn s -> s |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  def part1(data) do
    data |> Enum.map(&predict_next_number/1) |> Enum.sum()
  end

  def part2(data) do
    data |> Enum.map(&predict_prev_number/1) |> Enum.sum()
  end

  def predict_next_number(list) do
    [last_num | _] = list |> Enum.reverse()

    if list |> Enum.all?(fn n -> n == 0 end) do
      0
    else
      last_num + predict_next_number(delta_list(list))
    end
  end

  def delta_list(list) do
    {list, _} =
      list
      |> Enum.reduce({[], nil}, fn
        n, {[], nil} -> {[], n}
        n, {list, prev} -> {[n - prev | list], n}
      end)

    list |> Enum.reverse()
  end

  def predict_prev_number(list) do
    [first_num | _] = list

    if list |> Enum.all?(fn n -> n == 0 end) do
      0
    else
      first_num - predict_prev_number(delta_list(list))
    end
  end
end
