defmodule Day15 do
  Code.compile_file("priority_queue.ex")

  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-15")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data(data), do: prepare_data(data, %{}, 0, 0)

  def prepare_data([], grid, y, x), do: {grid, y - 1, x}

  def prepare_data([row | rest], grid, y, _) do
    {grid, x} = prepare_row(row |> String.split("", trim: true), grid, y, 0)
    prepare_data(rest, grid, y + 1, x)
  end

  def prepare_row([], grid, _, x), do: {grid, x - 1}

  def prepare_row([i | rest], grid, y, x),
    do: prepare_row(rest, grid |> Map.put({x, y}, String.to_integer(i)), y, x + 1)

  def part1({grid, tgty, tgtx}) do
    a_star_this_sucker(
      PriorityQueue.new() |> PriorityQueue.add(0, {0, {0, 0}}),
      grid,
      MapSet.new(),
      {tgtx, tgty},
      {tgtx + 1, tgty + 1},
      0
    )
  end

  def part2({grid, tgty, tgtx}) do
    a_star_this_sucker(
      PriorityQueue.new() |> PriorityQueue.add(0, {0, {0, 0}}),
      grid,
      MapSet.new(),
      {(tgtx + 1) * 5 - 1, (tgty + 1) * 5 - 1},
      {tgtx + 1, tgty + 1},
      0
    )
  end

  def a_star_this_sucker(
        pq,
        grid,
        seen,
        {tgtx, tgty} = tgt,
        {orig_sizex, orig_sizey} = size,
        states
      ) do
    {{weight, {x, y} = coord}, pq} = pq |> PriorityQueue.pop_next()

    cond do
      MapSet.member?(seen, x * 1000 + y) ->
        a_star_this_sucker(pq, grid, seen, tgt, size, states + 1)

      x == tgtx and y == tgty ->
        "states: #{states}" |> IO.puts()
        weight

      true ->
        [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
        |> Enum.filter(fn
          {x, y} when x >= 0 and y >= 0 and x <= tgtx and y <= tgty ->
            not MapSet.member?(seen, x * 1000 + y)

          _ ->
            false
        end)
        |> Enum.reduce(pq, fn
          {x, y} = c, pq ->
            val =
              case grid[c] do
                nil ->
                  rem(
                    grid[{rem(x, orig_sizex), rem(y, orig_sizey)}] + div(x, orig_sizex) +
                      div(y, orig_sizey) - 1,
                    9
                  ) + 1

                val ->
                  val
              end

            pq
            |> PriorityQueue.add(
              weight + val - (tgtx - x) - (tgty - y),
              {weight + val, c}
            )
        end)
        |> a_star_this_sucker(grid, seen |> MapSet.put(x * 1000 + y), tgt, size, states + 1)
    end
  end
end
