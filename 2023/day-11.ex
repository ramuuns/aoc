defmodule Day11 do
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
    "...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-11")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data) do
    {y_set, x_set, galaxies, y, x} =
      data
      |> Enum.reduce(
        {MapSet.new(), MapSet.new(), [], 0, 0},
        fn
          row, {y_set, x_set, galaxies, y, _} ->
            {y_set, x_set, galaxies, x} =
              row
              |> String.split("", trim: true)
              |> Enum.reduce(
                {y_set, x_set, galaxies, 0},
                fn
                  ".", {y_set, x_set, galaxies, x} ->
                    {y_set, x_set, galaxies, x + 1}

                  "#", {y_set, x_set, galaxies, x} ->
                    {y_set |> MapSet.put(y), x_set |> MapSet.put(x), [{y, x} | galaxies], x + 1}
                end
              )

            {y_set, x_set, galaxies, y + 1, x}
        end
      )

    {y_set, x_set, galaxies, {y, x}}
  end

  def part1({y_set, x_set, galaxies, {max_y, max_x}}) do
    galaxies =
      galaxies
      |> expand(y_set, max_y, 1, {1, 0})
      |> expand(x_set, max_x, 1, {0, 1})

    md_sum(galaxies, 0)
  end

  def part2({y_set, x_set, galaxies, {max_y, max_x}}) do
    galaxies =
      galaxies
      |> expand(y_set, max_y, 1_000_000 - 1, {1, 0})
      |> expand(x_set, max_x, 1_000_000 - 1, {0, 1})

    md_sum(galaxies, 0)
  end

  def expand(galaxies, _, 0, _, _), do: galaxies

  def expand(galaxies, set, coord, amount, vec) do
    if MapSet.member?(set, coord) do
      galaxies
      |> expand(set, coord - 1, amount, vec)
    else
      galaxies
      |> expand_galaxy([], coord, amount, vec)
      |> expand(set, coord - 1, amount, vec)
    end
  end

  def expand_galaxy([], expanded, _, _, _), do: expanded

  def expand_galaxy([{gy, gx} | rest], expanded, coord, amount, {y, x})
      when coord * y <= gy and coord * x <= gx,
      do:
        expand_galaxy(
          rest,
          [{gy + y * amount, gx + x * amount} | expanded],
          coord,
          amount,
          {y, x}
        )

  def expand_galaxy([g | rest], expanded, coord, amount, vec),
    do: expand_galaxy(rest, [g | expanded], coord, amount, vec)

  def md_sum([], sum), do: sum

  def md_sum([galaxy | rest], sum) do
    md_sum(rest, md_sum_inner(galaxy, rest, sum))
  end

  def md_sum_inner(_, [], sum), do: sum

  def md_sum_inner(galaxy, [other_galaxy | rest], sum) do
    md_sum_inner(galaxy, rest, sum + md(galaxy, other_galaxy))
  end

  def md({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end
end
