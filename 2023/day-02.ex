defmodule Day2 do
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
    "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-02")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    data
    |> Enum.map(fn line ->
      ["Game " <> game_id, rest_of_line] = line |> String.split(": ")
      game_id = game_id |> String.to_integer()

      cubesets =
        rest_of_line
        |> String.split("; ")
        |> Enum.map(fn cs_string ->
          cs_string
          |> String.split(", ")
          |> Enum.map(fn num_col ->
            [num, color] = num_col |> String.split(" ")
            {num |> String.to_integer(), color |> String.to_atom()}
          end)
        end)

      {game_id, cubesets}
    end)
  end

  def part1(data) do
    data
    |> Enum.filter(&possible_game/1)
    |> Enum.reduce(0, fn {id, _}, acc -> acc + id end)
  end

  def part2(data) do
    data
    |> Enum.map(&power_of_fewest_cubes_per_game/1)
    |> Enum.sum()
  end

  def possible_game({_, cubesets}) do
    is_cubeset_possible(cubesets, true)
  end

  def is_cubeset_possible(_, false), do: false
  def is_cubeset_possible([], true), do: true

  def is_cubeset_possible([set | rest], _) do
    is_cubeset_possible(rest, is_color_possible(set))
  end

  def is_color_possible([]), do: true
  def is_color_possible([{num, :red} | rest]) when num <= 12, do: is_color_possible(rest)
  def is_color_possible([{num, :green} | rest]) when num <= 13, do: is_color_possible(rest)
  def is_color_possible([{num, :blue} | rest]) when num <= 14, do: is_color_possible(rest)
  def is_color_possible(_), do: false

  def power_of_fewest_cubes_per_game({_, cubesets}) do
    {r, g, b} =
      cubesets
      |> Enum.reduce({0, 0, 0}, &cubeset_to_minrgb/2)

    r * g * b
  end

  def cubeset_to_minrgb([], rgb), do: rgb

  def cubeset_to_minrgb([{num, :red} | rest], {red, green, blue}) when num > red,
    do: cubeset_to_minrgb(rest, {num, green, blue})

  def cubeset_to_minrgb([{num, :green} | rest], {red, green, blue}) when num > green,
    do: cubeset_to_minrgb(rest, {red, num, blue})

  def cubeset_to_minrgb([{num, :blue} | rest], {red, green, blue}) when num > blue,
    do: cubeset_to_minrgb(rest, {red, green, num})

  def cubeset_to_minrgb([_ | rest], rgb), do: cubeset_to_minrgb(rest, rgb)
end
