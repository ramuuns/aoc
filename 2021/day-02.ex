defmodule Day2 do
  def run(mode) do
    data = read_input(mode)

    { 
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "forward 5
down 5
forward 8
up 3
down 8
forward 2"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-02")
    |> Enum.filter(fn n -> n |> String.trim() != "" end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn
      "forward " <> amount ->
        {:forward, amount}

      "up " <> amount ->
        {:up, amount}

      "down " <> amount ->
        {:down, amount}
    end)
    |> Enum.map(fn {dir, amount} -> {dir, amount |> String.to_integer()} end)
  end

  def part1(data), do: part1(data, {0, 0})
  def part1([], {x, y}), do: x * y
  def part1([{:up, delta} | tail], {x, y}), do: part1(tail, {x, y - delta})
  def part1([{:down, delta} | tail], {x, y}), do: part1(tail, {x, y + delta})
  def part1([{:forward, delta} | tail], {x, y}), do: part1(tail, {x + delta, y})

  def part2(data), do: part2(data, {0, 0, 0})
  def part2([], {x, y, _aim}), do: x * y
  def part2([{:up, delta} | tail], {x, y, aim}), do: part2(tail, {x, y, aim - delta})
  def part2([{:down, delta} | tail], {x, y, aim}), do: part2(tail, {x, y, aim + delta})

  def part2([{:forward, delta} | tail], {x, y, aim}),
    do: part2(tail, {x + delta, y + aim * delta, aim})
end

