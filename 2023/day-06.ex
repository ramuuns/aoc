defmodule Day6 do
  def run(mode) do
    data = read_input(mode, 1)
    data2 = read_input(mode, 2)

    [{1, data}, {2, data2}]
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

  def read_input(:test, part) do
    "Time:      7  15   30
Distance:  9  40  200"
    |> String.split("\n")
    |> prepare_data(part)
  end

  def read_input(:actual, part) do
    File.stream!("input-06")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data(part)
  end

  def prepare_data(data, 1) do
    [time, distance] =
      data
      |> Enum.map(fn s ->
        [_, amounts] = s |> String.split(":", trim: true)
        amounts |> String.split(~r"\s+", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    Enum.zip(time, distance)
  end

  def prepare_data(data, 2) do
    [time, distance] =
      data
      |> Enum.map(fn s ->
        [_, amounts] = s |> String.split(":", trim: true)
        amounts |> String.replace(~r"\s+", "") |> String.to_integer()
      end)

    {time, distance}
  end

  def part1(data) do
    data |> Enum.map(&win_count/1) |> Enum.reduce(1, fn wc, p -> p * wc end)
  end

  def part2(data) do
    win_count(data)
  end

  def win_count({time, distance}) do
    min = wc_min({time, distance}, 0, div(time, 2))
    max = wc_max({time, distance}, 0, div(time, 2))
    max - (min - 1)
  end

  def wc_min({time, distance}, min, _)
      when (time - min) * min > distance and (time - (min - 1)) * (min - 1) <= distance,
      do: min

  def wc_min({time, distance}, min, interval) when (time - min) * min > distance do
    wc_min({time, distance}, min - interval, Enum.max([div(interval, 2), 1]))
  end

  def wc_min({time, distance}, min, interval)
      when (time - min) * min < distance and (time - min) * min < (time - (min - 1)) * (min - 1) do
    wc_min({time, distance}, min - interval, Enum.max([div(interval, 2), 1]))
  end

  def wc_min(td, min, interval) do
    wc_min(td, min + interval, Enum.max([div(interval, 2), 1]))
  end

  def wc_max({time, distance}, max, _)
      when (time - max) * max > distance and (time - (max + 1)) * (max + 1) <= distance,
      do: max

  def wc_max({time, distance}, max, interval) when (time - max) * max > distance do
    wc_max({time, distance}, max + interval, Enum.max([div(interval, 2), 1]))
  end

  def wc_max({time, distance}, max, interval)
      when (time - max) * max < distance and (time - max) * max < (time - (max + 1)) * (max + 1) do
    wc_max({time, distance}, max + interval, Enum.max([div(interval, 2), 1]))
  end

  def wc_max(td, max, interval) do
    wc_max(td, max - interval, Enum.max([div(interval, 2), 1]))
  end
end
