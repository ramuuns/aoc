defmodule Day4 do
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
    "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-04")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn data ->
      ["Card " <> card_num, numbers] =
        data
        |> String.split(": ")

      card_num = card_num |> String.trim() |> String.to_integer()
      [winning_nr, your_nr] = numbers |> String.split(" | ")

      winning_nr =
        winning_nr
        |> String.split(~r"\s+", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      your_nr =
        your_nr
        |> String.split(~r"\s+", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      {card_num, winning_nr, your_nr}
    end)
  end

  def part1(data) do
    data
    |> Enum.map(&get_points_for_card/1)
    |> Enum.sum()
  end

  def part2(data) do
    initial_cards =
      data |> Enum.reduce(Map.new(), fn {id, _, _}, map -> map |> Map.put(id, 1) end)

    count_winning_cards(data, initial_cards)
  end

  def get_points_for_card({_, winning_num, your_num}) do
    win_count =
      MapSet.intersection(winning_num, your_num)
      |> Enum.count()

    if win_count == 0 do
      0
    else
      2 ** (win_count - 1)
    end
  end

  def count_winning_cards([], map), do: map |> Map.values() |> Enum.sum()

  def count_winning_cards([{id, winning_num, your_num} | rest], map) do
    win_count =
      MapSet.intersection(winning_num, your_num)
      |> Enum.count()

    if win_count == 0 do
      count_winning_cards(rest, map)
    else
      count_winning_cards(
        rest,
        1..win_count
        |> Enum.reduce(map, fn i, map ->
          map |> Map.put(id + i, Map.get(map, id + i) + Map.get(map, id))
        end)
      )
    end
  end
end
